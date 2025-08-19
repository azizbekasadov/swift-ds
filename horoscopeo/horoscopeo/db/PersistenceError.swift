public enum PersistenceError: Error {
    case notFound
    case duplicate
    case underlying(Error)
    case corruptPayload
    case unsupported
}