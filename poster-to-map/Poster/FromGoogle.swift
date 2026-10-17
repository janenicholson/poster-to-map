//
//  FromGoogle.swift
//  poster-to-map
//
//  Created by Google's AI on 16/10/2026.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

struct KeystoneView: View {
    @State private var keystoneAngle: Double = 15.0 // Degrees of distortion

    var body: some View {
        VStack {
            // Your Target View
            Image("your_image_or_view")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 200)
                .projectionEffect(keystoneTransform(angle: keystoneAngle))

            Slider(value: $keystoneAngle, in: -45...45)
                .padding()
        }
    }

    // Helper to generate the 3D projection matrix
    func keystoneTransform(angle: Double) -> ProjectionTransform {
        var transform = CATransform3DIdentity

        // m34 adds perspective (distortion over distance).
        // A smaller denominator equals stronger perspective warping.
        transform.m34 = -1.0 / 500.0

        // Rotate along the X-axis to mimic vertical projector tilting
        transform = CATransform3DRotate(
            transform,
            CGFloat(angle * .pi / 180.0),
            1, 0, 0
        )

        return ProjectionTransform(transform)
    }
}

func applyKeystoneCorrection(to inputImage: UIImage) -> UIImage? {
    guard let ciImage = CIImage(image: inputImage) else { return nil }

    let filter = CIFilter.keystoneCorrectionVertical()
    filter.inputImage = ciImage

    // Define custom quad points where the image has been warped
    filter.topLeft = CGPoint(x: 0, y: 1000)
    filter.topRight = CGPoint(x: 2000, y: 1000)
    filter.bottomLeft = CGPoint(x: 200, y: 0)     // Pulled in horizontally
    filter.bottomRight = CGPoint(x: 1800, y: 0)  // Pulled in horizontally
    filter.focalLength = 24.0

    let context = CIContext()
    if let outputCIImage = filter.outputImage,
       let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
        return UIImage(cgImage: cgImage)
    }

    return nil
}

struct PerspectiveAdjustmentView: View {
    // Canvas size parameters
    private let width: CGFloat = 300
    private let height: CGFloat = 300

    // Core state tracking the location of the 4 interactive corners
    @State private var topLeft = CGPoint(x: 20, y: 20)
    @State private var topRight = CGPoint(x: 280, y: 20)
    @State private var bottomRight = CGPoint(x: 280, y: 280)
    @State private var bottomLeft = CGPoint(x: 20, y: 280)

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // 1. The target view you want to bound/warp
                Image("document_scan_preview")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
                    .opacity(0.6)

                // 2. The overlay quad highlighting the selection zone
                QuadrilateralShape(tl: topLeft, tr: topRight, br: bottomRight, bl: bottomLeft)
                    .stroke(Color.blue, lineWidth: 2)
                    .background(
                        QuadrilateralShape(tl: topLeft, tr: topRight, br: bottomRight, bl: bottomLeft)
                            .fill(Color.blue.opacity(0.15))
                    )

                // 3. Interactive Corner Handles
                CornerHandle(position: $topLeft, boundaryWidth: width, boundaryHeight: height)
                CornerHandle(position: $topRight, boundaryWidth: width, boundaryHeight: height)
                CornerHandle(position: $bottomRight, boundaryWidth: width, boundaryHeight: height)
                CornerHandle(position: $bottomLeft, boundaryWidth: width, boundaryHeight: height)
            }
            .frame(width: width, height: height)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(radius: 5)

            // Output data reading out the current absolute points
            // perfect for passing straight to CoreImage CIPerspectiveCorrection
            VStack(alignment: .leading, spacing: 5) {
                Text("CoreImage Normalized Points:").font(.headline)
                Text("Top Left: (\(Int(topLeft.x)), \(Int(topLeft.y)))")
                Text("Top Right: (\(Int(topRight.x)), \(Int(topRight.y)))")
            }
            .font(.caption)
            .monospaced()
        }
    }
}

// Custom shape that draws lines dynamically between vectors
struct QuadrilateralShape: Shape {
    var tl: CGPoint
    var tr: CGPoint
    var br: CGPoint
    var bl: CGPoint

    // Enables clean animation if coordinates shift programmatically
    var animatableData: AnimatablePair<AnimatablePair<CGPoint, CGPoint>, AnimatablePair<CGPoint, CGPoint>> {
        get { .init(.init(tl, tr), .init(br, bl)) }
        set {
            tl = newValue.first.first
            tr = newValue.first.second
            br = newValue.second.first
            bl = newValue.second.second
        }
    }

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

// Reusable individual draggable node component
struct CornerHandle: View {
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

struct LoupeOverlayView: View {
    let targetImage: Image
    let touchPoint: CGPoint
    let isDragging: Bool
    let canvasSize: CGSize

    // Configuration properties
    private let loupeSize: CGFloat = 80
    private let magnificationScale: CGFloat = 2.0
    private let verticalOffset: CGFloat = -60 // Hovers finger to avoid obstruction

    var body: some View {
        if isDragging {
            // The Magnifying Glass Pod
            ZStack {
                // 1. Clip and scale the identical image asset
                targetImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: canvasSize.width, height: canvasSize.height)
                    // Anchor scaling directly from where the user touches
                    .scaleEffect(magnificationScale, anchor: UnitPoint(
                        x: touchPoint.x / canvasSize.width,
                        y: touchPoint.y / canvasSize.height
                    ))
                    .frame(width: loupeSize, height: loupeSize)
                    .clipShape(Circle())

                // 2. Crosshair indicator for pixel precision
                Circle()
                    .stroke(Color.white, lineWidth: 1)
                    .frame(width: 6, height: 6)

                // 3. High-contrast border frame
                Circle()
                    .stroke(Color.white, lineWidth: 2.5)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            }
            // Position the loupe right directly over the drag point, shifted vertically
            .position(x: touchPoint.x, y: touchPoint.y + verticalOffset)
            .transition(.opacity.combined(with: .scale(scale: 0.8)))
        }
    }
}

struct PrecisionPerspectiveView: View {
    private let canvasSize = CGSize(width: 320, height: 320)
    private let targetImage = Image("document_scan_preview") // Replace with asset

    @State private var topLeft = CGPoint(x: 30, y: 30)
    @State private var topRight = CGPoint(x: 290, y: 30)
    @State private var bottomRight = CGPoint(x: 290, y: 290)
    @State private var bottomLeft = CGPoint(x: 30, y: 290)

    // Shared state driving the loupe layer
    @State private var currentTouchPoint: CGPoint = .zero
    @State private var isCurrentlyDragging: Bool = false

    var body: some View {
        ZStack {
            // Underlay: Target Document Frame
            targetImage
                .resizable()
                .scaledToFill()
                .frame(width: canvasSize.width, height: canvasSize.height)
                .clipped()

            // Middle: Core UI Lines Selection
            QuadrilateralShape(tl: topLeft, tr: topRight, br: bottomRight, bl: bottomLeft)
                .stroke(Color.blue, lineWidth: 2)

            // Interactive Handles
            Group {
                precisionHandle(for: $topLeft)
                precisionHandle(for: $topRight)
                precisionHandle(for: $bottomRight)
                precisionHandle(for: $bottomLeft)
            }

            // Overlay: Floating Precision Loupe Glass
            LoupeOverlayView(
                targetImage: targetImage,
                touchPoint: currentTouchPoint,
                isDragging: isCurrentlyDragging,
                canvasSize: canvasSize
            )
            .animation(.easeOut(duration: 0.15), value: isCurrentlyDragging)
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    // Node Builder mutating active coordinates
    @ViewBuilder
    private func precisionHandle(for bindingsPoint: Binding<CGPoint>) -> some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 20, height: 20)
            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
            .position(bindingsPoint.wrappedValue)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isCurrentlyDragging = true

                        // Limit movement bounding rect
                        let validX = min(max(value.location.x, 0), canvasSize.width)
                        let validY = min(max(value.location.y, 0), canvasSize.height)
                        let boundedVector = CGPoint(x: validX, y: validY)

                        bindingsPoint.wrappedValue = boundedVector
                        currentTouchPoint = boundedVector
                    }
                    .onEnded { _ in
                        isCurrentlyDragging = false
                    }
            )
    }
}
