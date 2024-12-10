//
//  NoorQuranApp.swift
//  NoorQuran
//
//  Created by Tes Essa on 10/17/24.
//

import SwiftUI
@main
struct NoorQuranApp: App {
    @StateObject var memorizationStore = MemorizationStore()
    @StateObject var bookmarkAyahStore = BookmarkAyahStore()
    @StateObject var bookmarkHadithStore = BookmarkHadithStore()
    @StateObject private var audioManager = AudioManager()
    
    
    var body: some Scene {
        WindowGroup {
            AppLoadingView()
                .environmentObject(memorizationStore)
                .environmentObject(bookmarkAyahStore)
                .environmentObject(bookmarkHadithStore)
                .environmentObject(audioManager)
        }
    }
}


