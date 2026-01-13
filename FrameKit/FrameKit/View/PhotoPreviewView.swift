//
//  PhotoPreviewView.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import SwiftUI

struct PhotoPreviewView: View {
    
    let image: UIImage
    let onExport: () async -> Void
    let onDelete: () async -> Void
    let onDismiss: () -> Void
    
    @State private var showDeleteConfirmation = false
    @State private var isExporting = false
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
                    Button {
                        Task {
                            isExporting = true
                            await onExport()
                            isExporting = false
                        }
                    } label: {
                        if isExporting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .disabled(isExporting)
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
