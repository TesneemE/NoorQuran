//
//  PlayButton.swift
//  NoorQuran
//
//  Created by Tes Essa on 12/3/24.
//

import SwiftUI
import AVFoundation
struct PlayButton: View {
    @ObservedObject var surahStore: SurahStore
    @EnvironmentObject var audioManager: AudioManager
    var surahDetail: SurahDetail
    var ayah: Ayah
    @Binding var isAudioPlayerVisible: Bool
    let firstAyahAudioURL = "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3" // first Ayah audio
    
    var body: some View {
        Button(action: {
//            print(surahDetail.number)
//            print(ayah.numberInSurah)
            
            // stop current playback so no overlapping audio
            audioManager.stopAudio()
            
            surahStore.fetchAyahAudioUrl(surahNumber: surahDetail.number, ayahNumber: ayah.numberInSurah) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let audioUrl):
                        var audioURLs: [URL] = []
                        
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
                        audioManager.loadAudio(urls: audioURLs)
                        
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
                .foregroundColor(Color("Pink"))
        }
        .padding(.leading, 10)
    }
}
//struct PlayButton_Previews: PreviewProvider {
//    static var mockAudioManager: AudioManager = {
//        let manager = AudioManager()
//        manager.isPlaying = true
//        manager.totalTime = 180.0 // 3 minutes
//        manager.currentTime = 60.0 // 1 minute elapsed
//        return manager
//    }()
//    static var previews: some View {
//        PlayButton()
//            .environmentObject(mockAudioManager)
//    }
//}
