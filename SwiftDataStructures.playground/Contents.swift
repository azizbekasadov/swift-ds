import Foundation

// MARK: - Stacks
public struct Stack<Element> {
    private var storage: [Element] = []
    
    private var isEmpty: Bool {
        peek() == nil
    }
    
        
    public init(storage: [Element] = []) {
        self.storage = storage
    }
    
    public func peek() -> Element? {
        return storage.last
    }
    
    public mutating func push(_ element: Element) {
        storage.append(element)
    }
    
    @discardableResult
    public mutating func pop() -> Element? {
        guard !isEmpty else { return nil }
        return storage.popLast()
    }
}

extension Stack: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        storage = elements
    }
}
    
extension Stack: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        ----top----
        \(storage.map { "\($0)" }.reversed().joined(separator:"\n"))
        -----------
        """
    }
}


