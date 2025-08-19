
fileprivate final class CoreDataBackend: PersistenceBackend {
    private let container: NSPersistentContainer
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(kind: PersistenceController.StoreKind) throws {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "GenericStore", managedObjectModel: model)

        switch kind {
        case .inMemory:
            let d = NSPersistentStoreDescription()
            d.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [d]
        case .onDisk(let url):
            let d = NSPersistentStoreDescription(url: url.appendingPathComponent("GenericStore.sqlite"))
            container.persistentStoreDescriptions = [d]
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true

        var loadError: Error?
        container.loadPersistentStores { _, err in loadError = err }
        if let loadError { throw PersistenceError.underlying(loadError) }
    }

    // MARK: - PersistenceBackend

    func upsert<T: Persistable>(_ model: T) async throws -> T {
        try await upsertMany([model])
        return model
    }

    func upsertMany<T: Persistable>(_ models: [T]) async throws {
        guard !models.isEmpty else { return }
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        try await ctx.perform {
            for m in models {
                let record = try self.findOrInsertRecord(for: m, in: ctx)
                record.collection = T.collection
                record.id = String(m.id)
                record.payload = try self.encoder.encode(m)
                record.updatedAt = Date()
                if record.createdAt == nil { record.createdAt = record.updatedAt }
            }
            if ctx.hasChanges { try ctx.save() }
        }
    }

    func fetchAll<T: Persistable>(_ type: T.Type, query: Query<T>) async throws -> [T] {
        let ctx = container.viewContext
        let data: [Data] = try await ctx.perform {
            let fr = NSFetchRequest<CDRecord>(entityName: "CDRecord")
            fr.predicate = NSPredicate(format: "collection == %@", T.collection)
            let objects = try ctx.fetch(fr)
            return objects.compactMap { $0.payload }
        }
        var decoded = try data.map { try decoder.decode(T.self, from: $0) }
        if let f = query.whereMatches { decoded = decoded.filter(f) }
        if let s = query.sort { decoded = decoded.sorted(by: s) }
        if let o = query.offset { decoded = Array(decoded.dropFirst(o)) }
        if let l = query.limit { decoded = Array(decoded.prefix(l)) }
        return decoded
    }

    func fetchByID<T: Persistable>(_ type: T.Type, id: T.ID) async throws -> T? {
        let ctx = container.viewContext
        guard let payload = try await ctx.perform({
            let fr = NSFetchRequest<CDRecord>(entityName: "CDRecord")
            fr.fetchLimit = 1
            fr.predicate = NSPredicate(format: "collection == %@ AND id == %@", T.collection, String(id))
            return try ctx.fetch(fr).first?.payload
        }) else { return nil }
        return try decoder.decode(T.self, from: payload)
    }

    func deleteByID<T: Persistable>(_ type: T.Type, id: T.ID) async throws {
        let ctx = container.newBackgroundContext()
        try await ctx.perform {
            let fr = NSFetchRequest<CDRecord>(entityName: "CDRecord")
            fr.fetchLimit = 1
            fr.predicate = NSPredicate(format: "collection == %@ AND id == %@", T.collection, String(id))
            if let obj = try ctx.fetch(fr).first {
                ctx.delete(obj)
                if ctx.hasChanges { try ctx.save() }
            }
        }
    }

    func deleteAll<T: Persistable>(_ type: T.Type) async throws {
        let ctx = container.newBackgroundContext()
        try await ctx.perform {
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "CDRecord")
            fr.predicate = NSPredicate(format: "collection == %@", T.collection)
            let req = NSBatchDeleteRequest(fetchRequest: fr)
            req.resultType = .resultTypeObjectIDs
            _ = try ctx.execute(req) as? NSBatchDeleteResult
        }
    }

    func count<T: Persistable>(_ type: T.Type, query: Query<T>) async throws -> Int {
        // For now, count after decoding if filters are provided (storage-agnostic).
        // If no in-memory filter, use fast Core Data count.
        if query.whereMatches == nil {
            let ctx = container.viewContext
            return try await ctx.perform {
                let fr = NSFetchRequest<NSNumber>(entityName: "CDRecord")
                fr.predicate = NSPredicate(format: "collection == %@", T.collection)
                fr.resultType = .countResultType
                return try ctx.count(for: fr as! NSFetchRequest<NSFetchRequestResult>)
            }
        } else {
            return try await fetchAll(T.self, query: query).count
        }
    }

    // MARK: - Helpers

    private func findOrInsertRecord<T: Persistable>(for model: T, in ctx: NSManagedObjectContext) throws -> CDRecord {
        let fr = NSFetchRequest<CDRecord>(entityName: "CDRecord")
        fr.fetchLimit = 1
        fr.predicate = NSPredicate(format: "collection == %@ AND id == %@", T.collection, String(model.id))
        if let exist = try ctx.fetch(fr).first {
            return exist
        }
        let entity = NSEntityDescription.entity(forEntityName: "CDRecord", in: ctx)!
        let obj = CDRecord(entity: entity, insertInto: ctx)
        obj.collection = T.collection
        obj.id = String(model.id)
        return obj
    }

    // Programmatic model (no .xcdatamodel required)
    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "CDRecord"
        entity.managedObjectClassName = NSStringFromClass(CDRecord.self)

        // Attributes
        let collection = NSAttributeDescription()
        collection.name = "collection"
        collection.attributeType = .stringAttributeType
        collection.isOptional = false
        collection.indexed = true

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .stringAttributeType
        id.isOptional = false
        id.indexed = true

        let payload = NSAttributeDescription()
        payload.name = "payload"
        payload.attributeType = .binaryDataAttributeType
        payload.isOptional = false
        payload.allowsExternalBinaryDataStorage = true

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = true

        let updatedAt = NSAttributeDescription()
        updatedAt.name = "updatedAt"
        updatedAt.attributeType = .dateAttributeType
        updatedAt.isOptional = true

        entity.properties = [collection, id, payload, createdAt, updatedAt]

        // Unique constraint on (collection, id)
        entity.uniquenessConstraints = [["collection", "id"]]

        model.entities = [entity]
        return model
    }
}
