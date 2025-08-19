//
//  StronixVPNAppApp.swift
//  StronixVPNApp
//
//  Created by Azizbek Asadov on 18.08.2025.
//

import SwiftUI

@main
struct StronixVPNAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
