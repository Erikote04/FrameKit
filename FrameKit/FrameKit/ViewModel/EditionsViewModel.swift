//
//  EditionsViewModel.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import SwiftUI

enum SortOption: String, CaseIterable {
    case captureDate = "Capture Date"
    case modifiedDate = "Modification Date"
    case fileName = "File Name"
}

@Observable
final class EditionsViewModel {
    
    var framedPhotos: [FramedPhoto] = []
    var selectedPhotos: Set<FramedPhoto.ID> = []
    var isSelectionMode = false
    var selectedPhoto: FramedPhoto?
    var sortOption: SortOption = .modifiedDate
    var isAscending = false
    
    private let storageService: StorageService
    
    init(storageService: StorageService) {
        self.storageService = storageService
    }
    
    func loadFramedPhotos() {
        framedPhotos = storageService.fetchAllFramedPhotos(sortBy: sortOption, ascending: isAscending)
    }
    
    func setSortOption(_ option: SortOption) {
        sortOption = option
        loadFramedPhotos()
    }
    
    func toggleSortOrder() {
        isAscending.toggle()
        loadFramedPhotos()
    }
    
    func openPhoto(_ photo: FramedPhoto) {
        selectedPhoto = photo
        try? storageService.updatePhotoLastModified(photo)
    }
    
    func toggleSelection(for photo: FramedPhoto) {
        if selectedPhotos.contains(photo.id) {
            selectedPhotos.remove(photo.id)
        } else {
            selectedPhotos.insert(photo.id)
        }
    }
    
    func selectAll() {
        selectedPhotos = Set(framedPhotos.map { $0.id })
    }
    
    func clearSelection() {
        selectedPhotos.removeAll()
        isSelectionMode = false
    }
    
    func enterSelectionMode(with photo: FramedPhoto) {
        isSelectionMode = true
        selectedPhotos.insert(photo.id)
    }
    
    func deleteSelectedPhotos() throws {
        let photosToDelete = framedPhotos.filter { selectedPhotos.contains($0.id) }
        try storageService.deleteFramedPhotos(photosToDelete)
        loadFramedPhotos()
        clearSelection()
    }
    
    func deletePhoto(_ photo: FramedPhoto) throws {
        try storageService.deleteFramedPhoto(photo)
        loadFramedPhotos()
        selectedPhoto = nil
    }
    
    func getSelectedImages() -> [UIImage] {
        framedPhotos
            .filter { selectedPhotos.contains($0.id) }
            .compactMap { UIImage(data: $0.framedImageData) }
    }
    
    var selectionTitle: String {
        let count = selectedPhotos.count
        return count == 1 ? "1 Item Selected" : "\(count) Items Selected"
    }
    
    var canPerformActions: Bool {
        !selectedPhotos.isEmpty
    }
}
