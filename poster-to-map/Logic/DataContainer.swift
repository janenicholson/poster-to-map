//
//  DataContainer.swift
//  GratefulMoments
//
//  Created by Jane Nicholson on 08/10/2026.
//

import SwiftData
import SwiftUI

@Observable
@MainActor
class DataContainer {
    let modelContainer: ModelContainer

    var context: ModelContext {
        modelContainer.mainContext
    }

    init(includeSampleData: Bool = false) {
        let schema = Schema([
            Poster.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: includeSampleData)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

            if includeSampleData {
                try loadSampleData()
            }
            try context.save()
        }
        catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    func save(poster: Poster) {
        do {
            context.insert(poster)
            try context.save()
        }
        catch {
            fatalError("Could not save Map: \(error)")
        }
    }

    func update() {
        do {
            try context.save()
        }
        catch {
            fatalError("Could not save modified Map \(error)")
        }
    }

    func delete(poster: Poster) {
        context.delete(poster)
        do {
            try context.save()
        }
        catch {
            fatalError("Could not delete Map: \(error)")
        }
    }

    private func loadSampleData() throws {
        context.insert(Poster(title: "Wellington Zoo", imageData: UIImage(named: "Wellington Zoo Map")?.pngData()))
        context.insert(Poster(title: "New poster"))
    }
}

private let sampleContainer = DataContainer(includeSampleData: true)

extension View {
    func sampleDataContainer() -> some View {
        self
            .environment(sampleContainer)
            .modelContainer(sampleContainer.modelContainer)
    }
}
