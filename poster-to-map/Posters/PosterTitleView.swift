//
//  PosterTitleView.swift
//  poster-to-map
//
//  Created by Jane Nicholson on 23/10/2026.
//

import SwiftUI

struct PosterTitleView: View {
    @Binding var title : String

    var body: some View {
        TextField(text: $title) {
            Text("Title (Required)")
                .font(.title)
        }
        .font(.title)
    }
}

#Preview {
    @Previewable @State var title = ""
    PosterTitleView(title: $title)
        .sampleDataContainer()
}
