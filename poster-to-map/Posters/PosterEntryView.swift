//
//  PosterEntryView.swift
//  poster-to-map
//
//  Created by Jane Nicholson on 23/10/2026.
//

import SwiftUI

struct PosterEntryView: View {
    @State private var title = ""
    @State private var imageData: Data?

    @Environment(\.dismiss) private var dismiss
    @Environment(DataContainer.self) private var dataContainer

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center) {
                    PosterTitleView(title: $title)
                    PosterDateView(date: Date())
                    PosterPhotoPicker(imageData: $imageData)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CancelButtonView(isEmpty: title.isEmpty && imageData == nil, prompt: "Discard Map")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", systemImage: "checkmark") {
                        let newPoster = Poster(
                            title: title,
                            imageData: imageData
                        )
                        dataContainer.save(poster: newPoster)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PosterEntryView()
        .sampleDataContainer()
}
