//
//  SurahListView.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/24/24.
//

import SwiftUI
import AVFoundation

struct SurahListView: View {
    @EnvironmentObject var memorizationStore: MemorizationStore
    @EnvironmentObject var bookmarkAyahStore: BookmarkAyahStore
    @EnvironmentObject var audioManager: AudioManager
    @StateObject var store = SurahStore()
    @State private var searchTerm: String = "" //  variable for search input

    init() {
        // Customizing UINavigationBar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(Color("Green")).withAlphaComponent(0.1) 

        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("Green"), Color("AccentGreen")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)

                VStack(spacing: 16) {
                    TextField("Search Surah by number or name", text: $searchTerm)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal)

                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(store.surahs, id: \.number) { surah in
                                    NavigationLink(destination: SurahView(surahNumber: surah.number)) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("\(surah.number). \(surah.englishName)")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                Text(surah.name)
                                                    .font(.subheadline)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            Spacer()
                                            Text("\(surah.numberOfAyahs) Ayahs")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(6)
                                                .background(Capsule().fill(Color("Pink").opacity(0.7)))
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color("AccentPink").opacity(0.8))
                                                .shadow(radius: 5)
                                        )
                                    }
                                    .id(surah.number)
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                        .onChange(of: searchTerm) { newValue in
                            if let searchNumber = Int(newValue) {
                                if let surah = store.surahs.first(where: { $0.number == searchNumber }) {
                                    withAnimation {
                                        proxy.scrollTo(surah.number, anchor: .top)
                                    }
                                }
                            } else if !newValue.isEmpty {
                                let matchingSurahs = store.surahs.filter {
                                    $0.name.lowercased().contains(newValue.lowercased()) ||
                                    $0.englishName.lowercased().contains(newValue.lowercased())
                                }
                                if let firstMatch = matchingSurahs.first {
                                    withAnimation {
                                        proxy.scrollTo(firstMatch.number, anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                }
                        .onDisappear{
                            audioManager.stopAudio()
                        }
                .onAppear {
                    audioManager.stopAudio()
                    if store.surahs.isEmpty {
                        store.fetchSurahs()
                    }
                }
                .navigationTitle("Surahs")
                .navigationBarBackButtonHidden(false)
                .accentColor(.white) // for making the navigation title color and back button  white
            }
        }
        .tint(.white) // also changes the back button (and other navigation buttons) to white
    }
}

struct SurahListView_Previews: PreviewProvider {
    static var bookmarkStore: BookmarkAyahStore = {
        let store = BookmarkAyahStore()
        store.bookmarkedAyahs = [
            BookmarkedAyah(surah: 1, surahName: "Al-Fatiha", ayah: 1, text: ""),
            BookmarkedAyah(surah: 2, surahName: "Al-Baqara", ayah: 255, text: "")
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
        SurahListView()
            .environmentObject(bookmarkStore)
            .environmentObject(store)
            .environmentObject(mockAudioManager)
            }
        }
