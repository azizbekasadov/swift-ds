import Foundation

public enum NetworkError: Error, Equatable {
    case invalidURL
    case encodingFailed
    case transport(Error)               // URLSession transport error
    case unacceptableStatus(Int, Data?) // non-2xx
    case decodingFailed(Error, Data?)   // Decodable failed
    case cancelled
    case tooManyRetries
}