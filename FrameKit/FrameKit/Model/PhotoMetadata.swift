//
//  PhotoMetaData.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import Foundation

struct PhotoMetadata {
    let deviceModel: String
    let focalLength: String
    let aperture: String
    let shutterSpeed: String
    let iso: String
    
    var formattedDevice: String {
        "Shot on \(deviceModel)"
    }
    
    var formattedSpecs: String {
        "\(focalLength) \(aperture) \(shutterSpeed) \(iso)"
    }
}
