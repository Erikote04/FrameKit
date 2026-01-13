//
//  PhotoLibraryService.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import Photos
import UIKit

final class PhotoLibraryService {
    
    static let shared = PhotoLibraryService()
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
    }
    
    func fetchAllPhotos() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return PHAsset.fetchAssets(with: .image, options: options)
    }
    
    func loadImage(from asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
    
    func loadFullResolutionImage(from asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            options.resizeMode = .none
            
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .default,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
    
    func extractMetadata(from asset: PHAsset) -> PhotoMetadata? {
        guard let resource = PHAssetResource.assetResources(for: asset).first else {
            return nil
        }
        
        let deviceModel = asset.extractDeviceModel() ?? "iPhone"
        let focalLength = asset.extractFocalLength() ?? "24mm"
        let aperture = asset.extractAperture() ?? "f/1.8"
        let shutterSpeed = asset.extractShutterSpeed() ?? "1/120s"
        let iso = asset.extractISO() ?? "ISO 100"
        
        return PhotoMetadata(
            deviceModel: deviceModel,
            focalLength: focalLength,
            aperture: aperture,
            shutterSpeed: shutterSpeed,
            iso: iso
        )
    }
    
    func saveToLibrary(_ image: UIImage) async -> Bool {
        guard await requestAuthorization() else { return false }
        
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, _ in
                continuation.resume(returning: success)
            }
        }
    }
    
    func deleteFromLibrary(_ asset: PHAsset) async -> Bool {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            }) { success, _ in
                continuation.resume(returning: success)
            }
        }
    }
}

private extension PHAsset {
    
    func extractDeviceModel() -> String? {
        guard let resources = PHAssetResource.assetResources(for: self).first else {
            return nil
        }
        return resources.value(forKey: "uniformTypeIdentifier") as? String
    }
    
    func extractFocalLength() -> String? {
        guard let focalLength = self.value(forKey: "focalLength") as? Double else {
            return nil
        }
        return "\(Int(focalLength))mm"
    }
    
    func extractAperture() -> String? {
        guard let aperture = self.value(forKey: "aperture") as? Double else {
            return nil
        }
        return "ƒ/\(String(format: "%.1f", aperture))"
    }
    
    func extractShutterSpeed() -> String? {
        guard let speed = self.value(forKey: "exposureTime") as? Double else {
            return nil
        }
        
        if speed >= 1 {
            return "\(Int(speed))s"
        } else {
            let denominator = Int(1 / speed)
            return "1/\(denominator)s"
        }
    }
    
    func extractISO() -> String? {
        guard let iso = self.value(forKey: "ISO") as? Int else {
            return nil
        }
        return "ISO \(iso)"
    }
}
