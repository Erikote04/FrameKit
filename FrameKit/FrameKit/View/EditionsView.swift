//
//  EditionsView.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import SwiftUI

struct EditionsView: View {
    
    @State private var viewModel: EditionsViewModel
    @State private var showPreview = false
    @State private var showDeleteConfirmation = false
    
    init(storageService: StorageService) {
        _viewModel = State(initialValue: EditionsViewModel(storageService: storageService))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.framedPhotos.isEmpty {
                    emptyState
                } else {
                    photosGrid
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.isSelectionMode ? viewModel.selectionTitle : "")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isSelectionMode {
                        selectionToolbar
                    } else {
                        Button("Select") {
                            viewModel.isSelectionMode = true
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadFramedPhotos()
            }
            .sheet(isPresented: $showPreview) {
                if let photo = viewModel.selectedPhoto,
                   let image = UIImage(data: photo.framedImageData) {
                    PhotoPreviewView(
                        image: image,
                        isFromGallery: false,
                        onExport: {},
                        onDelete: {
                            try? viewModel.deletePhoto(photo)
                        },
                        onDismiss: {
                            viewModel.selectedPhoto = nil
                        }
                    )
                }
            }
            .confirmationDialog(
                "Delete \(viewModel.selectedPhotos.count) \(viewModel.selectedPhotos.count == 1 ? "photo" : "photos")?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    try? viewModel.deleteSelectedPhotos()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    private var photosGrid: some View {
        ScrollView {
            AdaptivePhotoGrid(
                photos: viewModel.framedPhotos,
                isSelectionMode: viewModel.isSelectionMode,
                selectedPhotos: viewModel.selectedPhotos,
                onPhotoTap: { photo in
                    if viewModel.isSelectionMode {
                        viewModel.toggleSelection(for: photo)
                    } else {
                        viewModel.selectedPhoto = photo
                        showPreview = true
                    }
                },
                onPhotoLongPress: { photo in
                    viewModel.enterSelectionMode(with: photo)
                }
            )
            .padding()
        }
    }
    
    private var selectionToolbar: some View {
        HStack(spacing: 16) {
            Button("Select All") {
                viewModel.selectAll()
            }
            
            ShareLink(
                item: Image(uiImage: viewModel.getSelectedImages().first ?? UIImage()),
                preview: SharePreview("Framed Photos")
            ) {
                Image(systemName: "square.and.arrow.up")
            }
            .disabled(!viewModel.canPerformActions)
            
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
            }
            .disabled(!viewModel.canPerformActions)
            
            Button("Cancel") {
                viewModel.clearSelection()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.stack")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Framed Photos")
                .font(.headline)
            
            Text("Photos you frame will appear here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
