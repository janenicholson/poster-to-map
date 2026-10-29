//
//  PosterPhotoPicker.swift
//  poster-to-map
//
//  Created by Jane Nicholson on 23/10/2026.
//

import SwiftUI
import PhotosUI

struct PosterPhotoPicker: View {
    @Binding var imageData: Data?
    @State private var newImage: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $newImage) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
            else {
                Image(systemName: "photo.badge.plus.fill")
                    .font(.largeTitle)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .background(Color(white: 0.4, opacity: 0.32))
            }
        }
        .onChange(of: newImage) {
            guard let newImage else { return }
            Task {
                imageData = try await newImage.loadTransferable(type: Data.self)
            }
        }

    }
}

#Preview {
    @Previewable @State var zoo = UIImage(named: "Wellington Zoo Map")?.pngData()
    PosterPhotoPicker(imageData: $zoo)
}
#Preview("empty") {
    @Previewable @State var notFound = UIImage(named: "WellingtonZoo")?.pngData()
    PosterPhotoPicker(imageData: $notFound)
}
