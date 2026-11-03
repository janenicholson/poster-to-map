//
//  CornerHandle.swift
//  poster-to-map
//
//  Created by Jane Nicholson on 16/10/2026.
//

import SwiftUI

#Preview {
    @Previewable @State var position = CGPoint(x: 50, y: 50)
    DragPoint(position: $position, boundaryWidth: 300, boundaryHeight: 300)
}

// Reusable individual draggable node component
struct DragPoint: View {
    @Binding var position: CGPoint
    let boundaryWidth: CGFloat
    let boundaryHeight: CGFloat

    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 24, height: 24)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(radius: 3)
            // Absolute overlay layout position
            .position(position)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Enforce drag boundaries inside the frame canvas space
                        let validatedX = min(max(value.location.x, 0), boundaryWidth)
                        let validatedY = min(max(value.location.y, 0), boundaryHeight)
                        self.position = CGPoint(x: validatedX, y: validatedY)
                    }
            )
    }
}
