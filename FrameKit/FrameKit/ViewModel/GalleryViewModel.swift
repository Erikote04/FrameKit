//
//  GalleryViewModel.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import SwiftUI
import Photos

@Observable
final class GalleryViewModel {
    
    var photos: [PHAsset] = []
    var isAuthorized = false
    var selectedAsset: PHAsset?
    var selectedImage: UIImage?
    var framedImage: UIImage?
    var metadata: PhotoMetadata?
    
    private let photoLibraryService = PhotoLibraryService.shared
    private let frameGenerator = FrameGenerator()
    
    func requestAuthorization() async {
        isAuthorized = await photoLibraryService.requestAuthorization()
        if isAuthorized {
            loadPhotos()
        }
    }
    
    func loadPhotos() {
        let fetchResult = photoLibraryService.fetchAllPhotos()
        photos = fetchResult.objects(at: IndexSet(0..<fetchResult.count))
    }
    
    func selectPhoto(_ asset: PHAsset) async -> Bool {
        selectedAsset = asset
        
        guard let image = await photoLibraryService.loadFullResolutionImage(from: asset) else {
            return false
        }
        
        selectedImage = image
        metadata = await photoLibraryService.extractMetadata(from: asset)
        
        guard let metadata = metadata else {
            clearSelection()
            return false
        }
        
        framedImage = frameGenerator.generateFramedImage(
            from: image,
            metadata: metadata
        )
        
        return true
    }
    
    func saveFramedPhoto(storageService: StorageService) async throws {
        guard let originalImage = selectedImage,
              let framedImage = framedImage,
              let metadata = metadata,
              let asset = selectedAsset else {
            return
        }
        
        let aspectRatio = originalImage.size.width / originalImage.size.height
        let captureDate = asset.creationDate ?? Date()
        
        try storageService.saveFramedPhoto(
            originalImage: originalImage,
            framedImage: framedImage,
            metadata: metadata,
            aspectRatio: aspectRatio,
            captureDate: captureDate
        )
    }
    
    func deleteSelectedPhoto() async -> Bool {
        guard let asset = selectedAsset else {
            return false
        }
        
        let success = await photoLibraryService.deleteFromLibrary(asset)
        
        if success {
            selectedAsset = nil
            selectedImage = nil
            framedImage = nil
            metadata = nil
            loadPhotos()
        }
        
        return success
    }
    
    func clearSelection() {
        selectedAsset = nil
        selectedImage = nil
        framedImage = nil
        metadata = nil
    }
}
