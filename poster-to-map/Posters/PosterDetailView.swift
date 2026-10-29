//
//  PosterDetailView.swift
//  poster-to-map
//
//  Created by Jane Nicholson on 18/10/2026.
//

import SwiftUI

struct PosterDetailView: View {
    @State var poster: Poster
    @State var unchanged = true
    @State var title : String
    @State var imageData : Data?

    @Environment(\.dismiss) private var dismiss
    @Environment(DataContainer.self) private var dataContainer

    init(poster:Poster) {
        self._poster = State(initialValue: poster)
        self._title = State(initialValue: poster.title)
        self._imageData = State(initialValue: poster.imageData)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center) {
                    PosterTitleView(title: $title)
                    PosterDateView(date: poster.timestamp)
                    PosterPhotoPicker(imageData: $imageData)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: poster.title) {
                unchanged = false
            }
            .onChange(of: poster.imageData) {
                unchanged = false
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CancelButtonView(isEmpty: unchanged, prompt: "Discard Map")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", systemImage: "checkmark") {
                        poster.title = title
                        poster.imageData = imageData
                        dataContainer.update()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview{
    PosterDetailView(poster: Poster(
        title: "Wellington Zoo",
        imageData: UIImage(named: "Wellington Zoo Map")?
            .pngData(),
        timestamp: .now.addingTimeInterval(-24*60*60)
    ))
    .sampleDataContainer()
}
