//
//  GalleryView.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import SwiftUI
import Photos

struct GalleryView: View {
    
    @State private var viewModel = GalleryViewModel()
    @State private var showPreview = false
    @State private var showInvalidPhotoAlert = false
    
    let storageService: StorageService
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 4)
    private let thumbnailSize = CGSize(width: 300, height: 300)
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isAuthorized {
                    photoGrid
                } else {
                    authorizationPrompt
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.requestAuthorization()
            }
            .alert("Invalid Photo", isPresented: $showInvalidPhotoAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("This photo cannot be framed. Only photos taken with a camera are supported. Screenshots are not compatible.")
            }
            .fullScreenCover(isPresented: $showPreview) {
                if let framedImage = viewModel.framedImage {
                    PhotoPreviewView(
                        image: framedImage,
                        onSave: {
                            await handleSave()
                        },
                        onDelete: {
                            await handleDelete()
                        },
                        onDismiss: {
                            viewModel.clearSelection()
                        }
                    )
                }
            }
        }
    }
    
    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewModel.photos, id: \.localIdentifier) { asset in
                    PhotoGridItem(
                        asset: asset,
                        thumbnailSize: thumbnailSize
                    )
                    .onTapGesture {
                        Task {
                            let hasMetadata = await viewModel.selectPhoto(asset)
                            if hasMetadata {
                                showPreview = true
                            } else {
                                showInvalidPhotoAlert = true
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    private var authorizationPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Photo Library Access Required")
                .font(.headline)
            
            Text("FrameKit needs access to your photos to add custom frames.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Grant Access") {
                Task {
                    await viewModel.requestAuthorization()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func handleSave() async {
        do {
            try await viewModel.saveFramedPhoto(storageService: storageService)
        } catch {
            print("Failed to save framed photo")
        }
    }
    
    private func handleDelete() async {
        _ = await viewModel.deleteSelectedPhoto()
    }
}
