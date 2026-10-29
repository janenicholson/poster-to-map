//
//  PosterTimeView.swift
//  poster-to-map
//
//  Created by Jane Nicholson on 23/10/2026.
//

import SwiftUI

struct PosterDateView: View {
    var date: Date
    var body: some View {
        Text(date, style: .date)
            .font(.caption2)
    }
}

#Preview {
    PosterDateView(date: .now.addingTimeInterval(-24*60*60))
    PosterDateView(date: .now.addingTimeInterval(-3*24*60*60))
}
