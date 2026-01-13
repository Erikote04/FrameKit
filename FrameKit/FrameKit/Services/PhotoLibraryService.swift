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
    
    func extractMetadata(from asset: PHAsset) async -> PhotoMetadata? {
        await withCheckedContinuation { continuation in
            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            
            asset.requestContentEditingInput(with: options) { input, _ in
                guard let input = input,
                      let imageSource = CGImageSourceCreateWithURL(input.fullSizeImageURL! as CFURL, nil),
                      let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any],
                      let exif = properties[kCGImagePropertyExifDictionary as String] as? [String: Any],
                      let tiff = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let deviceModel = (tiff[kCGImagePropertyTIFFModel as String] as? String) ?? "iPhone"
                
                let focalLength: String
                if let focalLengthValue = exif[kCGImagePropertyExifFocalLength as String] as? Double {
                    focalLength = "\(Int(focalLengthValue))mm"
                } else {
                    focalLength = "24mm"
                }
                
                let aperture: String
                if let apertureValue = exif[kCGImagePropertyExifFNumber as String] as? Double {
                    aperture = "ƒ/\(String(format: "%.1f", apertureValue))"
                } else {
                    aperture = "ƒ/1.8"
                }
                
                let shutterSpeed: String
                if let exposureTime = exif[kCGImagePropertyExifExposureTime as String] as? Double {
                    if exposureTime >= 1 {
                        shutterSpeed = "\(Int(exposureTime))s"
                    } else {
                        let denominator = Int(1 / exposureTime)
                        shutterSpeed = "1/\(denominator)s"
                    }
                } else {
                    shutterSpeed = "1/120s"
                }
                
                let iso: String
                if let isoArray = exif[kCGImagePropertyExifISOSpeedRatings as String] as? [Int],
                   let isoValue = isoArray.first {
                    iso = "ISO \(isoValue)"
                } else {
                    iso = "ISO 100"
                }
                
                let metadata = PhotoMetadata(
                    deviceModel: deviceModel,
                    focalLength: focalLength,
                    aperture: aperture,
                    shutterSpeed: shutterSpeed,
                    iso: iso
                )
                
                continuation.resume(returning: metadata)
            }
        }
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
