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
    
    private let rowHeight: CGFloat = 200
    private let spacing: CGFloat = 8
    
    var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(groupedPhotos(), id: \.0) { row in
                HStack(spacing: spacing) {
                    ForEach(row.1, id: \.id) { photo in
                        photoItem(photo, width: calculateWidth(for: photo, in: row.1))
                    }
                }
            }
        }
    }
    
    private func photoItem(_ photo: FramedPhoto, width: CGFloat) -> some View {
        ZStack(alignment: .topTrailing) {
            if let image = UIImage(data: photo.framedImageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: rowHeight)
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
    
    private func groupedPhotos() -> [(Int, [FramedPhoto])] {
        var groups: [(Int, [FramedPhoto])] = []
        var currentRow: [FramedPhoto] = []
        var currentWidth: CGFloat = 0
        let maxWidth = UIScreen.main.bounds.width - 32
        
        for photo in photos {
            let photoWidth = rowHeight * photo.aspectRatio
            
            if currentWidth + photoWidth + spacing <= maxWidth {
                currentRow.append(photo)
                currentWidth += photoWidth + spacing
            } else {
                if !currentRow.isEmpty {
                    groups.append((groups.count, currentRow))
                }
                currentRow = [photo]
                currentWidth = photoWidth
            }
        }
        
        if !currentRow.isEmpty {
            groups.append((groups.count, currentRow))
        }
        
        return groups
    }
    
    private func calculateWidth(for photo: FramedPhoto, in row: [FramedPhoto]) -> CGFloat {
        let maxWidth = UIScreen.main.bounds.width - 32
        let totalSpacing = spacing * CGFloat(row.count - 1)
        let availableWidth = maxWidth - totalSpacing
        
        let totalAspectRatio = row.reduce(0.0) { $0 + $1.aspectRatio }
        
        return (availableWidth * photo.aspectRatio) / totalAspectRatio
    }
}
