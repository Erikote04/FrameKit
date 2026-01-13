//
//  StorageService.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import SwiftData
import UIKit

@Observable
final class StorageService {
    
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }
    
    func saveFramedPhoto(
        originalImage: UIImage,
        framedImage: UIImage,
        metadata: PhotoMetadata,
        aspectRatio: Double,
        captureDate: Date
    ) throws {
        guard let originalData = originalImage.pngData(),
              let framedData = framedImage.pngData() else {
            throw StorageError.imageConversionFailed
        }
        
        let photo = FramedPhoto(
            originalImageData: originalData,
            framedImageData: framedData,
            metadata: metadata.formattedSpecs,
            deviceModel: metadata.deviceModel,
            aspectRatio: aspectRatio,
            captureDate: captureDate
        )
        
        modelContext.insert(photo)
        try modelContext.save()
    }
    
    func fetchAllFramedPhotos(sortBy option: SortOption = .modifiedDate, ascending: Bool = false) -> [FramedPhoto] {
        let sortDescriptor: SortDescriptor<FramedPhoto>
        
        switch option {
        case .captureDate:
            sortDescriptor = SortDescriptor(\.captureDate, order: ascending ? .forward : .reverse)
        case .modifiedDate:
            sortDescriptor = SortDescriptor(\.lastModifiedDate, order: ascending ? .forward : .reverse)
        case .fileName:
            sortDescriptor = SortDescriptor(\.deviceModel, order: ascending ? .forward : .reverse)
        }
        
        let descriptor = FetchDescriptor<FramedPhoto>(sortBy: [sortDescriptor])
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }
    
    func updatePhotoLastModified(_ photo: FramedPhoto) throws {
        photo.updateLastModified()
        try modelContext.save()
    }
    
    func deleteFramedPhotos(_ photos: [FramedPhoto]) throws {
        for photo in photos {
            modelContext.delete(photo)
        }
        try modelContext.save()
    }
    
    func deleteFramedPhoto(_ photo: FramedPhoto) throws {
        modelContext.delete(photo)
        try modelContext.save()
    }
}
