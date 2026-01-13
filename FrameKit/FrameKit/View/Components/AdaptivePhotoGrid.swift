//
//  AdaptivePhotoGrid.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import SwiftUI

struct AdaptivePhotoGrid: View {
    
    let photos: [FramedPhoto]
    let isSelectionMode: Bool
    let selectedPhotos: Set<FramedPhoto.ID>
    let onPhotoTap: (FramedPhoto) -> Void
    let onPhotoLongPress: (FramedPhoto) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 4)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(photos, id: \.id) { photo in
                    photoItem(photo)
                }
            }
        }
    }
    
    private func photoItem(_ photo: FramedPhoto) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                if let image = UIImage(data: photo.framedImageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                        .overlay {
                            if isSelectionMode {
                                Rectangle()
                                    .strokeBorder(
                                        selectedPhotos.contains(photo.id) ? Color.blue : Color.clear,
                                        lineWidth: 3
                                    )
                            }
                        }
                        .onTapGesture {
                            onPhotoTap(photo)
                        }
                        .onLongPressGesture {
                            onPhotoLongPress(photo)
                        }
                }
                
                if isSelectionMode && selectedPhotos.contains(photo.id) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 28, height: 28)
                        .overlay {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(8)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
