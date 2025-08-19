
fileprivate protocol PersistenceBackend: AnyObject {
    func upsert<T: Persistable>(_ model: T) async throws -> T
    func upsertMany<T: Persistable>(_ models: [T]) async throws
    func fetchAll<T: Persistable>(_ type: T.Type, query: Query<T>) async throws -> [T]
    func fetchByID<T: Persistable>(_ type: T.Type, id: T.ID) async throws -> T?
    func deleteByID<T: Persistable>(_ type: T.Type, id: T.ID) async throws
    func deleteAll<T: Persistable>(_ type: T.Type) async throws
    func count<T: Persistable>(_ type: T.Type, query: Query<T>) async throws -> Int
}