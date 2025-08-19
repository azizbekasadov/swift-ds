//
//  MultipartFormData.swift
//  horoscopeo
//
//  Created by Azizbek Asadov on 11.08.2025.
//


import Foundation

public struct MultipartFormData {
    public struct Part {
        public var name: String
        public var filename: String?
        public var mimeType: String?
        public var data: Data
        public init(name: String, filename: String? = nil, mimeType: String? = nil, data: Data) {
            self.name = name; self.filename = filename; self.mimeType = mimeType; self.data = data
        }
    }

    public var parts: [Part]
    public init(parts: [Part] = []) { self.parts = parts }

    public func encode(boundary: String) -> (data: Data, contentType: String) {
        var body = Data()
        let prefix = "--\(boundary)\r\n"
        for p in parts {
            body.append(prefix.data(using: .utf8)!)
            var disp = "Content-Disposition: form-data; name=\"\(p.name)\""
            if let fn = p.filename { disp += "; filename=\"\(fn)\"" }
            body.append((disp + "\r\n").data(using: .utf8)!)
            if let mt = p.mimeType { body.append(("Content-Type: \(mt)\r\n").data(using: .utf8)!) }
            body.append("\r\n".data(using: .utf8)!)
            body.append(p.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        let ct = "multipart/form-data; boundary=\(boundary)"
        return (body, ct)
    }
}