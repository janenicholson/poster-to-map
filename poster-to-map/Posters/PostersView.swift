//
//  ContentView.swift
//  poster-to-map
//
//  Created by Jane Nicholson on 24/09/2026.
//

import SwiftUI
import SwiftData

struct PostersView: View {
    @State private var isCreatePoster = false

    @Environment(DataContainer.self) private var dataContainer

    @Query(sort: \Poster.timestamp) private var posters: [Poster]

    var body: some View {
        NavigationStack {
            List {
                ForEach(posters) { poster in
                    NavigationLink {
                        PosterDetailView(poster: poster)
                    } label: {
                        Text(poster.title)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        isCreatePoster = true
                    }
                    label: {
                        Label("Add Item", systemImage: "plus")
                    }
                    .sheet(isPresented: $isCreatePoster) {
                        PosterEntryView()
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { posters[$0] }.forEach(dataContainer.delete)
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    PostersView()
        .sampleDataContainer()
}
