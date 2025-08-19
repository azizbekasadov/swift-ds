//
//  UserDefaultOptional.swift
//  horoscopeo
//
//  Created by Azizbek Asadov on 11.08.2025.
//



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
