//
//  ContentView.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    private var storageService: StorageService {
        StorageService(modelContainer: modelContext.container)
    }
    
    var body: some View {
        TabView {
            GalleryView(storageService: storageService)
                .tabItem {
                    Label("Gallery", systemImage: "photo.on.rectangle")
                }
            
            EditionsView(storageService: storageService)
                .tabItem {
                    Label("Editions", systemImage: "photo.stack")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: FramedPhoto.self, inMemory: true)
}
