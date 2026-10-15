//
//  poster_to_mapApp.swift
//  poster-to-map
//
//  Created by Jane Nicholson on 24/09/2026.
//

import SwiftUI
import CoreData

@main
struct poster_to_mapApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
