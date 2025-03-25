//
//  StackOverflowToyApp.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import SwiftUI

@main
struct StackOverflowToyApp: App {
    // TODO: Implement ModelContainer should we need to save User to SwiftData
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            User.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            UserList()
                .environmentObject(GlobalDependencies.shared)
        }
//        .modelContainer(sharedModelContainer)
    }
}
