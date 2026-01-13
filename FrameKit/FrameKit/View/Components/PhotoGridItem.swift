//
//  PhotoGridItem.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import SwiftUI
import Photos

struct PhotoGridItem: View {
    
    let asset: PHAsset
    let thumbnailSize: CGSize
    
    @State private var thumbnail: UIImage?
    
    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fill)
            }
        }
        .clipped()
        .task {
            thumbnail = await PhotoLibraryService.shared.loadImage(
                from: asset,
                targetSize: thumbnailSize
            )
        }
    }
}
