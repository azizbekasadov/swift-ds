//
//  NavigationHost.swift
//  horoscopeo
//
//  Created by Azizbek Asadov on 09.08.2025.
//

import SwiftUI

@MainActor
public struct NavigationHost<Route: Hashable, Root: View, Destination: View>: View {
    @StateObject private var router: Router<Route>
    private let root: () -> Root
    private let destination: (Route) -> Destination

    public init(
        router: Router<Route>,
        @ViewBuilder root: @escaping () -> Root,
        @ViewBuilder destination: @escaping (Route) -> Destination
    ) {
        _router = StateObject(wrappedValue: router)
        self.root = root
        self.destination = destination
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            root()
                .navigationDestination(for: Route.self) { route in
                    destination(route)
                }
        }
        .environmentObject(router)
    }
}
