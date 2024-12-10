//
//  AudioPlayer.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/28/24.
// credit to https://github.com/Cebraiil/AudioPlayerTutorialSwiftUI/tree/main for audioplayer tutorial
import Foundation
import AVFoundation
import Combine

class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var totalTime: TimeInterval = 0.0
    @Published var currentTime: TimeInterval = 0.0
    @Published var repeatCount = 1

    private var playCount = 0
    private var currentAudioIndex = 0
    private var audioPlayers: [AVAudioPlayer] = []
    private var audioURLs: [URL] = []  // stores the list of audio URLs to play sequentially
    private var timer: Timer?
    private var isAudioLoading = false // tracks if audio is still loading
    
    private var isResettingAudio: Bool = false // flag to track audio reset state to make sure not resetting to much

    // for the errors- didn't work think it's my xcode
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session configured successfully.")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    func loadAudio(urls: [URL], resumePlayback: Bool = false) {
        stopAudio() // resets audioList and stops playing audio
        audioURLs = urls // updates the audio URLs
        currentAudioIndex = 0 // resets to the first audio index
        playCount = 0 // resets play count
        totalTime = 0.0 // resets the total time

        isAudioLoading = true

        let session = URLSession(configuration: .default)
        let group = DispatchGroup()

        for url in urls {
            group.enter()
            session.downloadTask(with: url) { [weak self] localURL, _, error in
                defer { group.leave() }
                guard let self = self, let localURL = localURL else {
                    if let error = error {
                        print("Error downloading audio: \(error.localizedDescription)")
                    }
                    return
                }
                do {
                    let player = try AVAudioPlayer(contentsOf: localURL)
                    player.delegate = self
                    player.prepareToPlay()
                    DispatchQueue.main.async {
                        self.audioPlayers.append(player)
                        if self.audioPlayers.count == 1 {
                            self.totalTime = player.duration
                        }
                    }
                } catch {
                    print("Error preparing audio for \(url): \(error.localizedDescription)")
                }
            }.resume()
        }

        group.notify(queue: .main) {
            self.isAudioLoading = false
            self.playAudio()  // Start playback after all audio files are loaded
        }
    }

    func playAudio() {
        guard !audioPlayers.isEmpty else {
            print("No audio loaded for playback.")
            return
        }
        guard currentAudioIndex < audioPlayers.count else {
            return
        }

        let player = audioPlayers[currentAudioIndex]
        player.play()
        isPlaying = true
        startUpdatingProgress()
    }

    func pauseAudio() {
        audioPlayers[currentAudioIndex].pause()
        isPlaying = false
        timer?.invalidate()  // to pause in audio player view
    }

    func stopAudio() {
        // check if the audio is already being reset to avoid multiple resets happening at once
        guard !isResettingAudio else { return }
        
        // Stop all audio players
        audioPlayers.forEach { $0.stop() }
        isPlaying = false

        // invalidate and clear progress timer
        timer?.invalidate()
        timer = nil
        currentTime = 0.0
        playCount = 0
        currentAudioIndex = 0
        
        // reset the list
        resetAudioList()
    }

    func resetAudioList() {
        // prevent multiple resets from happening simultaneously
        guard !isResettingAudio else { return }

        isResettingAudio = true
        
        audioPlayers.removeAll()  // clear the audio players
        audioURLs.removeAll()     // clear the audio URLs

        // after reset is done, mark resetting as complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isResettingAudio = false
        }
    }

    func seekAudio(to time: TimeInterval) {
        guard !audioPlayers.isEmpty else { return }
        audioPlayers[currentAudioIndex].currentTime = time
    }

    func cycleRepeatCount() {
        repeatCount = repeatCount % 5 + 1 // Cycles from 1 to 5
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if currentAudioIndex < audioPlayers.count - 1 {
            // Introduce a slight delay before starting the next audio
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.currentAudioIndex += 1
                self.audioPlayers[self.currentAudioIndex].play()
            }
        } else {
            // Cycle repeat if more than 1
            playCount += 1
            if playCount < repeatCount {
                currentAudioIndex = 0
                audioPlayers[currentAudioIndex].play()
            } else {
                isPlaying = false
                timer?.invalidate()  // Stop the progress timer when all files finish
            }
        }
    }

    private func startUpdatingProgress() {
        // gets rid of any existing timer before starting a new one
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
//updates progress of time when playing
    private func updateProgress() {
        guard !audioPlayers.isEmpty else { return }
        let currentPlayer = audioPlayers[currentAudioIndex]
        if currentPlayer.isPlaying {
            currentTime = currentPlayer.currentTime
        }
    }
}
