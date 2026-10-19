//
//  PosterDetailView.swift
//  poster-to-map
//
//  Created by Jane Nicholson on 18/10/2026.
//

import SwiftUI

struct PosterDetailView: View {
    var poster: Poster
    var body: some View {
        VStack(alignment: .center) {
            Text(poster.title)
                .font(.title)
            Text(poster.timestamp, style: .date)
                .font(.caption2)
            if let image = poster.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
        .padding()
    }
}

#Preview{
    PosterDetailView(poster: Poster(
        title: "Wellington Zoo",
        imageData: UIImage(named: "Wellington Zoo Map")?
            .pngData(),
        timestamp: .now.addingTimeInterval(-24*60*60)
    ))
}
