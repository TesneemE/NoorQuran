//
//  PlayButton.swift
//  NoorQuran
//
//  Created by Tes Essa on 12/3/24.
//

import SwiftUI

struct PlayButton: View {
    @ObservedObject var surahStore: SurahStore
    @ObservedObject var audioManager: AudioManager
    var surahDetail: SurahDetail
    var ayah: Ayah
    @Binding var isAudioPlayerVisible: Bool
    let firstAyahAudioURL = "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3" // Default URL for first Ayah audio
    
    var body: some View {
        Button(action: {
            print(surahDetail.number)
            print(ayah.numberInSurah)
            
            // Stop current playback to ensure no overlapping audio
            audioManager.stopAudio()
            
            surahStore.fetchAyahAudioUrl(surahNumber: surahDetail.number, ayahNumber: ayah.numberInSurah) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let audioUrl):
                        var audioURLs: [URL] = []
                        
                        // Determine the URLs for the audio
                        if ayah.numberInSurah == 1 && surahDetail.number != 1 && surahDetail.number != 9 {
                            if let firstAyahURL = URL(string: firstAyahAudioURL),
                               let ayahURL = URL(string: audioUrl) {
                                audioURLs = [firstAyahURL, ayahURL]
                            }
                        } else {
                            if let url = URL(string: audioUrl) {
                                audioURLs = [url]
                            }
                        }
                        
                        // Load audio and ensure correct order
                        audioManager.loadAudio(urls: audioURLs)
                        
                        // Toggle visibility only after audio is ready
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                isAudioPlayerVisible.toggle()
                            }
                        }
                    case .failure(let error):
                        print("Failed to fetch audio URL:", error.localizedDescription)
                    }
                }
            }
        }) {
            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
        }
        .padding(.leading, 10)
    }
}
