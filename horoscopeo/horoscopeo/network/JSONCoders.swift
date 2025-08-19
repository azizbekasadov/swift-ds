import Foundation

public enum JSONCoders {
    public static func decoder(dateStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) -> JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = dateStrategy
        return d
    }
    public static func encoder(dateStrategy: JSONEncoder.DateEncodingStrategy = .iso8601) -> JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = dateStrategy
        return e
    }
}