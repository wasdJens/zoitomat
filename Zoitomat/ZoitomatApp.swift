//
//  ZoitomatApp.swift
//  Zoitomat
//
//  Created by Jens Reiner on 09.01.25.
//

import SwiftUI
import SwiftData

@main
struct ZoitomatApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ZoitTimeEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
