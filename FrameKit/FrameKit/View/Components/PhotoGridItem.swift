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
        GeometryReader { geometry in
            Group {
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width, height: geometry.size.width)
                }
            }
            .clipped()
        }
        .aspectRatio(1, contentMode: .fit)
        .task {
            thumbnail = await PhotoLibraryService.shared.loadImage(
                from: asset,
                targetSize: thumbnailSize
            )
        }
    }
}
