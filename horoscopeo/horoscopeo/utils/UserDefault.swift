//
//  UserDefault.swift
//  horoscopeo
//
//  Created by Azizbek Asadov on 11.08.2025.
//



@propertyWrapper
public struct UserDefault<Value> {
    public let key: String
    public let name: String
    public var defaultValue: Value
    
    public var container: UserDefaults = .standard
    
    public var wrappedValue: Value {
        get {
            getFromUserDefaults(key: key) ?? defaultValue
        } set {
            saveToUserDefaults(value: newValue, name: name, key: key)
        }
    }
}

extension UserDefault {
    public func getFromUserDefaults(key: String) -> Value? {
        return container.object(forKey: key) as? Value ?? defaultValue
    }
    
    public func saveToUserDefaults(value: Value?, name: String,key: String) {
        if let new = value {
            print(">>> RT -> \(name) \(String(describing: new)) stored.")
            container.set(new, forKey: key)
        } else {
            print(">>> RT -> \(name) removed.")
            container.removeObject(forKey: key)
        }
    }
}


import Foundation

@propertyWrapper
public struct UserDefaultOptional<Value> {
    public let key: String
    public let name: String
    public var defaultValue: Value? = nil
    
    public var container: UserDefaults = .standard
    
    public var wrappedValue: Value? {
        get {
            return getFromUserDefaults(key: key)
        } set {
            saveToUserDefaults(value: newValue, name: name, key: key)
        }
    }
}

extension UserDefaultOptional {
    public func getFromUserDefaults(key: String) -> Value? {
        return container.object(forKey: key) as? Value ?? defaultValue
    }
    
    public func saveToUserDefaults(value: Value?,
                                    name: String,
                                    key: String) {
        if let new = value {
            print(">>> VPN -> \(name) \(String(describing: new)) stored.")
            container.set(new, forKey: key)
        } else {
            print(">>> VPN -> \(name) removed.")
            container.removeObject(forKey: key)
        }
    }
}
