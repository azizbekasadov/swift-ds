import Foundation

public protocol HTTPClient {
    func send<Response>(_ endpoint: Endpoint<Response>) async throws -> Response
}

@MainActor
public final class DefaultHTTPClient: HTTPClient {
    private let baseURL: URL
    private let session: URLSession
    private let adapters: [RequestAdapter]
    private let validators: [ResponseValidator]
    private let retryPolicy: RetryPolicy?

    public struct Configuration {
        public var timeout: TimeInterval
        public var cachePolicy: NSURLRequest.CachePolicy
        public var allowsConstrainedNetworkAccess: Bool
        public var allowsExpensiveNetworkAccess: Bool
        public init(
            timeout: TimeInterval = 30,
            cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy,
            allowsConstrainedNetworkAccess: Bool = true,
            allowsExpensiveNetworkAccess: Bool = true
        ) {
            self.timeout = timeout
            self.cachePolicy = cachePolicy
            self.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
            self.allowsExpensiveNetworkAccess = allowsExpensiveNetworkAccess
        }
    }

    public init(
        baseURL: URL,
        configuration: Configuration = .init(),
        sessionConfiguration: URLSessionConfiguration = .default,
        adapters: [RequestAdapter] = [],
        validators: [ResponseValidator] = [StatusCodeValidator()],
        retryPolicy: RetryPolicy? = ExponentialBackoffRetryPolicy()
    ) {
        self.baseURL = baseURL
        self.adapters = adapters
        self.validators = validators
        self.retryPolicy = retryPolicy

        sessionConfiguration.timeoutIntervalForRequest = configuration.timeout
        sessionConfiguration.requestCachePolicy = configuration.cachePolicy
        sessionConfiguration.allowsConstrainedNetworkAccess = configuration.allowsConstrainedNetworkAccess
        sessionConfiguration.allowsExpensiveNetworkAccess = configuration.allowsExpensiveNetworkAccess
        self.session = URLSession(configuration: sessionConfiguration)
    }

    public func send<Response>(_ endpoint: Endpoint<Response>) async throws -> Response {
        var attempt = 0
        while true {
            attempt += 1
            do {
                var request = try makeRequest(endpoint)
                for adapter in adapters {
                    request = try await adapter.adapt(request)
                }

                let (data, urlResponse) = try await session.data(for: request)
                guard let http = urlResponse as? HTTPURLResponse else { throw NetworkError.transport(URLError(.badServerResponse)) }

                for v in validators { try v.validate(data: data, response: http) }

                // Decode
                return try endpoint.decode(data, http)

            } catch {
                let response = (error as? URLError) == nil ? nil : nil // no response available in data(for:)
                if (error as? URLError)?.code == .cancelled { throw NetworkError.cancelled }

                if let retryPolicy,
                   let delay = retryPolicy.retryDelay(for: error, attempt: attempt, response: response) {
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }
                // Wrap URLSession errors uniformly
                if let urlError = error as? URLError {
                    throw NetworkError.transport(urlError)
                }
                throw error
            }
        }
    }

    private func makeRequest<Response>(_ endpoint: Endpoint<Response>) throws -> URLRequest {
        guard var comps = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        if !endpoint.query.isEmpty {
            comps.queryItems = endpoint.query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = comps.url else { throw NetworkError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = endpoint.method.rawValue
        req.allHTTPHeaderFields = endpoint.headers

        if let body = endpoint.body {
            switch body {
            case .empty:
                break
            case .data(let data, let contentType):
                req.httpBody = data
                req.setValue(contentType, forHTTPHeaderField: "Content-Type")
            case .json(let encodable, let encoder):
                do {
                    req.httpBody = try encoder.encode(AnyEncodable(encodable))
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch { throw NetworkError.encodingFailed }
            case .formURLEncoded(let params):
                let s = params
                    .map { key, value in "\(urlEncode(key))=\(urlEncode(value))" }
                    .joined(separator: "&")
                req.httpBody = s.data(using: .utf8)
                req.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            case .multipart(let form):
                let boundary = "Boundary-\(UUID().uuidString)"
                let encoded = form.encode(boundary: boundary)
                req.httpBody = encoded.data
                req.setValue(encoded.contentType, forHTTPHeaderField: "Content-Type")
            }
        }
        return req
    }

    private func urlEncode(_ s: String) -> String {
        s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
    }
}

// Helper to encode unknown Encodable value
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init(_ wrapped: Encodable) { _encode = wrapped.encode }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}