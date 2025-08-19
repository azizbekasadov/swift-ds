//
//  horoscopeoApp.swift
//  horoscopeo
//
//  Created by Azizbek Asadov on 11.08.2025.
//

import SwiftUI

@main
struct horoscopeoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
