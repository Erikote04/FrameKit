//
//  PhotoPreviewView.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import SwiftUI

struct PhotoPreviewView: View {
    
    let image: UIImage
    let onSave: () async -> Void
    let onDelete: () async -> Void
    let onDismiss: () -> Void
    
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical]) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                }
                .scrollIndicators(.hidden)
            }
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        onDismiss()
                        dismiss()
                    }
                    .tint(.white)
                }
                
                ToolbarItem {
                    ShareLink(item: Image(uiImage: image), preview: SharePreview("Framed Photo", image: Image(uiImage: image))) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .tint(.white)
                    .simultaneousGesture(TapGesture().onEnded {
                        Task {
                            await onSave()
                        }
                    })
                }
                
                ToolbarSpacer(.fixed)
                
                ToolbarItem {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
            }
            .confirmationDialog(
                "Delete Photo",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    Task {
                        await onDelete()
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
}
