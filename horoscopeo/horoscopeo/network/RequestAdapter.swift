import Foundation

public protocol RequestAdapter {
    func adapt(_ request: URLRequest) async throws -> URLRequest
}

public protocol ResponseValidator {
    func validate(data: Data, response: HTTPURLResponse) throws
}

// Example adapters/validators

public struct DefaultHeadersAdapter: RequestAdapter {
    private let headers: [String: String]
    public init(_ headers: [String: String]) { self.headers = headers }
    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var req = request
        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        return req
    }
}

public struct BearerTokenAdapter: RequestAdapter {
    private let tokenProvider: () async throws -> String?
    public init(tokenProvider: @escaping () async throws -> String?) { self.tokenProvider = tokenProvider }
    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var req = request
        if let token = try await tokenProvider() {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return req
    }
}

public struct StatusCodeValidator: ResponseValidator {
    private let acceptable: Range<Int>
    public init(acceptable: Range<Int> = 200..<300) { self.acceptable = acceptable }
    public func validate(data: Data, response: HTTPURLResponse) throws {
        guard acceptable.contains(response.statusCode) else {
            throw NetworkError.unacceptableStatus(response.statusCode, data)
        }
    }
}