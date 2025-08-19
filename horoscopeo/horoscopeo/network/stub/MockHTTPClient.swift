//
//  MockHTTPClient.swift
//  horoscopeo
//
//  Created by Azizbek Asadov on 11.08.2025.
//


import Foundation

public final class MockHTTPClient: HTTPClient {
    public typealias Handler = (Any) async throws -> Any
    private let handler: (Any) async throws -> Any

    public init<Response>(_ stub: @escaping (Endpoint<Response>) async throws -> Response) {
        self.handler = { any in
            guard let ep = any as? Endpoint<Response> else { fatalError("Type mismatch in MockHTTPClient") }
            return try await stub(ep)
        }
    }

    public func send<Response>(_ endpoint: Endpoint<Response>) async throws -> Response {
        // Force-cast is safe due to initializer contract.
        return try await handler(endpoint) as! Response
    }
}