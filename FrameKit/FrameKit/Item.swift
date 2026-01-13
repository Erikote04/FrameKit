//
//  Item.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
