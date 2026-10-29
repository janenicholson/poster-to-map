//
//  CancelButtonView.swift
//  poster-to-map
//
//  Created by Jane Nicholson on 23/10/2026.
//

import SwiftUI

struct CancelButtonView: View {
    var isEmpty: Bool
    var prompt: String

    @State private var isShowingCancelConfirmation = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button("Cancel", systemImage: "xmark") {
            if isEmpty {
                dismiss()
            }
            else {
                isShowingCancelConfirmation = true
            }
        }
        .confirmationDialog(prompt, isPresented: $isShowingCancelConfirmation) {
            Button(prompt, role: .destructive) {
                dismiss()
            }
        }
    }
}

#Preview {
    CancelButtonView(isEmpty: true, prompt: "Discard Map")
        .sampleDataContainer()
    CancelButtonView(isEmpty: false, prompt: "Discard Map")
        .sampleDataContainer()
}
