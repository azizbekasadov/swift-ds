//
//  Persistable.swift
//  horoscopeo
//
//  Created by Azizbek Asadov on 11.08.2025.
//


public protocol Persistable: Codable, Equatable {
    associatedtype ID: Hashable & LosslessStringConvertible
    static var collection: String { get }     // Logical bucket name, e.g. "affirmations"
    var id: ID { get }
}