//
//  FramedPhoto.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import Foundation
import SwiftData

@Model
final class FramedPhoto {
    var id: UUID
    var originalImageData: Data
    var framedImageData: Data
    var metadata: String
    var deviceModel: String
    var createdAt: Date
    var captureDate: Date
    var lastModifiedDate: Date
    var aspectRatio: Double
    
    init(
        id: UUID = UUID(),
        originalImageData: Data,
        framedImageData: Data,
        metadata: String,
        deviceModel: String,
        aspectRatio: Double,
        captureDate: Date
    ) {
        self.id = id
        self.originalImageData = originalImageData
        self.framedImageData = framedImageData
        self.metadata = metadata
        self.deviceModel = deviceModel
        self.createdAt = Date()
        self.captureDate = captureDate
        self.lastModifiedDate = Date()
        self.aspectRatio = aspectRatio
    }
    
    func updateLastModified() {
        self.lastModifiedDate = Date()
    }
}
