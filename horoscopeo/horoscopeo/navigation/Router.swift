//
//  Router.swift
//  horoscopeo
//
//  Created by Azizbek Asadov on 09.08.2025.
//

import Combine
import SwiftUI

@MainActor
public final class Router<Route: Hashable>: ObservableObject {
    @Published public var path: [Route] = []

    public init(path: [Route] = []) {
        self.path = path
    }

    // MARK: - Push / Pop

    @discardableResult
    public func push(_ route: Route) -> Self {
        path.append(route)
        return self
    }

    @discardableResult
    public func push<S: Sequence>(_ routes: S) -> Self where S.Element == Route {
        path.append(contentsOf: routes)
        return self
    }

    @discardableResult
    public func pop() -> Self {
        _ = path.popLast()
        return self
    }

    @discardableResult
    public func pop(to count: Int) -> Self {
        guard count >= 0, count <= path.count else { return self }
        path = Array(path.prefix(count))
        return self
    }

    @discardableResult
    public func popToRoot() -> Self {
        path.removeAll()
        return self
    }

    // MARK: - Replace / Set

    /// Replace the last element (no-op if empty).
    @discardableResult
    public func replace(with route: Route) -> Self {
        guard !path.isEmpty else { return push(route) }
        path[path.count - 1] = route
        return self
    }

    /// Replace the entire stack.
    @discardableResult
    public func setPath(_ newPath: [Route]) -> Self {
        path = newPath
        return self
    }

    /// Pop until the predicate returns true for the last element, or to root if none match.
    @discardableResult
    public func popTo(where predicate: (Route) -> Bool) -> Self {
        while let last = path.last, predicate(last) == false {
            path.removeLast()
        }
        return self
    }

    /// Navigate via a deep-link path (replaces stack).
    @discardableResult
    public func deepLink(_ routes: [Route]) -> Self {
        setPath(routes)
        return self
    }
}
