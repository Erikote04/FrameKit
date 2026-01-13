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
    
    private var currentDay: String {
        String(Calendar.current.component(.day, from: Date()))
    }
    
    init(storageService: StorageService) {
        _viewModel = State(initialValue: EditionsViewModel(storageService: storageService))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.framedPhotos.isEmpty {
                    emptyState
                } else {
                    photosContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.isSelectionMode ? viewModel.selectionTitle : "")
            .toolbar {
                    if viewModel.isSelectionMode {
                        ToolbarItem(placement: .topBarLeading) { deleteButton }
                        ToolbarItem { shareButton }
                        ToolbarItem { doneButton }
                    } else {
                        ToolbarItem { selectButton }
                        ToolbarSpacer(.fixed)
                        ToolbarItem { filterButton }
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
                        onSave: {},
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
    
    private var photosContent: some View {
        VStack(spacing: 0) {
            if viewModel.isSelectionMode {
                selectAllCheckbox
            }
            
            ScrollView {
                AdaptivePhotoGrid(
                    photos: viewModel.framedPhotos,
                    isSelectionMode: viewModel.isSelectionMode,
                    selectedPhotos: viewModel.selectedPhotos,
                    onPhotoTap: { photo in
                        if viewModel.isSelectionMode {
                            viewModel.toggleSelection(for: photo)
                        } else {
                            viewModel.openPhoto(photo)
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
    }
    
    private var selectAllCheckbox: some View {
        HStack {
            Button {
                if viewModel.selectedPhotos.count == viewModel.framedPhotos.count {
                    viewModel.clearSelection()
                    viewModel.isSelectionMode = true
                } else {
                    viewModel.selectAll()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: viewModel.selectedPhotos.count == viewModel.framedPhotos.count ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(viewModel.selectedPhotos.count == viewModel.framedPhotos.count ? .blue : .secondary)
                        .font(.title3)
                    
                    Text("Select All")
                        .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Spacer()
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    private var selectButton: some View {
        Button("Select") {
            viewModel.isSelectionMode = true
        }
    }
    
    private var filterButton: some View {
        Menu {
            Button {
                viewModel.setSortOption(.captureDate)
            } label: {
                Label("Capture Date", systemImage: viewModel.sortOption == .captureDate ? "checkmark" : "\(currentDay).calendar")
            }
            
            Button {
                viewModel.setSortOption(.modifiedDate)
            } label: {
                Label("Modification Date", systemImage: viewModel.sortOption == .modifiedDate ? "checkmark" : "square.and.pencil")
            }
            
            Button {
                viewModel.setSortOption(.fileName)
            } label: {
                Label("File Name", systemImage: viewModel.sortOption == .fileName ? "checkmark" : "document")
            }
            
            Divider()
            
            Button {
                viewModel.toggleSortOrder()
            } label: {
                Label("Reverse Order", systemImage: viewModel.isAscending ? "checkmark" : "arrow.up.arrow.down")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
        }
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Image(systemName: "trash")
        }
        .tint(.red)
    }
    
    private var shareButton: some View {
        ShareLink(
            item: Image(uiImage: viewModel.getSelectedImages().first ?? UIImage()),
            preview: SharePreview("Framed Photos")
        ) {
            Image(systemName: "square.and.arrow.up")
        }
    }
    
    private var doneButton: some View {
        Button(role: .confirm) {
            viewModel.clearSelection()
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
