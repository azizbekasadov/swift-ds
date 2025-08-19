import Foundation

/// Type-safe endpoint that knows how to decode its response.
public struct Endpoint<Response> {
    public var path: String
    public var method: HTTPMethod
    public var query: [String: String?]
    public var headers: [String: String]
    public var body: Body?
    public var decode: (Data, HTTPURLResponse) throws -> Response

    public enum Body {
        case empty
        case data(Data, contentType: String)
        case json(Encodable, encoder: JSONEncoder = .init())
        case formURLEncoded([String: String])
        case multipart(MultipartFormData)
    }

    public init(
        path: String,
        method: HTTPMethod = .GET,
        query: [String: String?] = [:],
        headers: [String: String] = [:],
        body: Body? = nil,
        decode: @escaping (Data, HTTPURLResponse) throws -> Response
    ) {
        self.path = path
        self.method = method
        self.query = query
        self.headers = headers
        self.body = body
        self.decode = decode
    }
}

public extension Endpoint where Response: Decodable {
    static func json(
        _ type: Response.Type = Response.self,
        path: String,
        method: HTTPMethod = .GET,
        query: [String: String?] = [:],
        headers: [String: String] = [:],
        body: Endpoint<Response>.Body? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) -> Endpoint<Response> {
        Endpoint<Response>(
            path: path,
            method: method,
            query: query,
            headers: headers,
            body: body,
            decode: { data, _ in
                do { return try decoder.decode(Response.self, from: data) }
                catch { throw NetworkError.decodingFailed(error, data) }
            }
        )
    }
}