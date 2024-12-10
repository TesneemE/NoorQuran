//
//  ContentView.swift
//  NoorQuran
//
//  Created by Tes Essa on 10/17/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bookmarkHadithStore: BookmarkHadithStore
    @EnvironmentObject var bookmarkAyahStore: BookmarkAyahStore
    @EnvironmentObject var memorizationStore: MemorizationStore
    @EnvironmentObject var audioManager: AudioManager
    var body: some View {
        TabView {
            Group{
                WelcomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                SurahListView()
                    .tabItem {
                        Label("Quran", systemImage: "book")
                    }
                HadithView()
                    .tabItem {
                        Label("Hadith", systemImage: "seal")
                    }
                BookmarkView()
                    .tabItem {
                        Label("Bookmarks", systemImage: "bookmark")
                    }
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color("Green"), for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var bookmarkStore: BookmarkAyahStore = {
        let store = BookmarkAyahStore()
        store.bookmarkedAyahs = [
            BookmarkedAyah(surah: 1, surahName: "Al-Fatiha", ayah: 1, text: "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ"),
            BookmarkedAyah(surah: 2, surahName: "Al-Baqara", ayah: 255, text: "")
        ]
        return store
    }()
    static var bookmarkHStore: BookmarkHadithStore = {
        let store = BookmarkHadithStore()
        store.bookmarkedHadiths = [
            BookmarkedHadith(hadithNum: "1", hadithText: "Al-Fatiha", hadithNarrator: ""),
        ]
        return store
    }()
    static var store: MemorizationStore = {
        let store = MemorizationStore()
        store.memorizedAyahs = [
            MemorizedAyah(surah: 1, surahName: "Al-Fatiha", ayah: 1, dateMemorized: Date()),
            MemorizedAyah(surah: 2, surahName: "Al-Baqara", ayah: 255, dateMemorized: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        ]
        return store
    }()
    static var mockAudioManager: AudioManager = {
        let manager = AudioManager()
        manager.isPlaying = true
        manager.totalTime = 180.0
        manager.currentTime = 60.0 
        return manager
    }()

    static var previews: some View {
        ContentView()
            .environmentObject(bookmarkStore)
            .environmentObject(store)
            .environmentObject(bookmarkHStore)
            .environmentObject(mockAudioManager)
        
        
    }
}
