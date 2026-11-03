//
//  PerspectiveAdjustmentView.swift
//  poster-to-map
//
//  Created by Jane Nicholson on 16/10/2026.
//

import SwiftUI

#Preview {
    PerspectiveAdjustmentView(image: UIImage(named: "Wellington Zoo Map")!)
}

struct PerspectiveAdjustmentView: View {
    var image: UIImage

    // Size of the image as it's displayed
    @State private var imageSize: CGSize = CGSize(width:10, height:10)

    // Location of the 4 corners as identified by the user
    @State private var topLeft: CGPoint = CGPoint(x:0, y:0)
    @State private var topRight: CGPoint = CGPoint(x:10, y:0)
    @State private var bottomRight: CGPoint = CGPoint(x:10, y:10)
    @State private var bottomLeft: CGPoint = CGPoint(x:0, y:10)

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipped()
                .opacity(0.6)
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        }
        action: { newValue in
            imageSize = newValue
            topLeft = CGPoint(x:0, y:0)
            topRight = CGPoint(x:imageSize.width, y:0)
            bottomLeft = CGPoint(x:0, y:imageSize.height)
            bottomRight = CGPoint(x:imageSize.width, y:imageSize.height)
        }.overlay {
            QuadrilateralShape(tl: topLeft, tr: topRight, br: bottomRight, bl: bottomLeft)
                .stroke(Color.blue, lineWidth: 2)

            DragPoint(position: $topLeft, boundaryWidth: imageSize.width, boundaryHeight: imageSize.height)
            DragPoint(position: $topRight, boundaryWidth: imageSize.width, boundaryHeight: imageSize.height)
            DragPoint(position: $bottomRight, boundaryWidth: imageSize.width, boundaryHeight: imageSize.height)
            DragPoint(position: $bottomLeft, boundaryWidth: imageSize.width, boundaryHeight: imageSize.height)
        }
        .padding(20)
    }
}

// Custom shape that draws lines dynamically between vectors
struct QuadrilateralShape: Shape {
    var tl: CGPoint
    var tr: CGPoint
    var br: CGPoint
    var bl: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: tl)
        path.addLine(to: tr)
        path.addLine(to: br)
        path.addLine(to: bl)
        path.closeSubpath()
        return path
    }
}
