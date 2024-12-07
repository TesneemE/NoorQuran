//
//  AudioPlayerView.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/28/24.
//
//

import SwiftUI
import AVKit

//struct AudioPlayerView: View {
//    @ObservedObject var audioManager: AudioManager
//
//    var body: some View {
//        VStack(spacing: 20) {
//            HStack {
//                Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                    .font(.largeTitle)
//                    .onTapGesture {
//                        audioManager.isPlaying ? audioManager.stopAudio() : audioManager.playAudio()
//                    }
//
//                Slider(value: Binding(get: {
//                    audioManager.currentTime
//                }, set: { newValue in
//                    audioManager.seekAudio(to: newValue)
//                }), in: 0...audioManager.totalTime)
//                .accentColor(.white)
//
//                Button(action: {
//                    audioManager.cycleRepeatCount()
//                }) {
//                    Text("\(audioManager.repeatCount)x")
//                        .font(.headline)
//                        .padding()
//                        .background(.ultraThinMaterial)
//                        .cornerRadius(10)
//                }
//            }
//
//            HStack {
//                Text(timeString(time: audioManager.currentTime))
//                    .foregroundColor(.white)
//                Spacer()
//                Text(timeString(time: audioManager.totalTime))
//                    .foregroundColor(.white)
//            }
//            .padding(.horizontal)
//        }
//        .padding()
//        .background(.ultraThinMaterial)
//        .cornerRadius(20)
//        .frame(maxWidth: .infinity)
//        .padding(.horizontal)
//        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
//            audioManager.updateProgress()
//        }
//    }
//
//    private func timeString(time: TimeInterval) -> String {
//        let minutes = Int(time) / 60
//        let seconds = Int(time) % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//}
struct AudioPlayerView: View {
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.largeTitle)
                    .onTapGesture {
                        audioManager.isPlaying ? audioManager.stopAudio() : audioManager.playAudio()
                    }

                Slider(value: Binding(get: {
                    audioManager.currentTime
                }, set: { newValue in
                    audioManager.seekAudio(to: newValue)
                }), in: 0...audioManager.totalTime)
                .accentColor(.white)

                Button(action: {
                    audioManager.cycleRepeatCount()
                }) {
                    Text("\(audioManager.repeatCount)x")
                        .font(.headline)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }

            HStack {
                Text(timeString(time: audioManager.currentTime))
                    .foregroundColor(.white)
                Spacer()
                Text(timeString(time: audioManager.totalTime))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView(audioManager: AudioManager())
    }
}
