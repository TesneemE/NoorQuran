//
//  AudioPlayer.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/28/24.
//
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
    private var audioURLs: [URL] = []  // Stores the list of audio URLs to play sequentially
    private var timer: Timer?  // For updating progress
    private var isAudioLoading = false // Track if audio is still loading

    /// Load audio for playback, clearing any existing audio data.
    func loadAudio(urls: [URL], resumePlayback: Bool = false) {
        stopAudio() // Stop any currently playing audio and reset state
        audioPlayers.removeAll() // Clear the previous audio players
        audioURLs = urls // Update the audio URLs
        currentAudioIndex = 0 // Reset to the first audio index
        playCount = 0 // Reset play count
        totalTime = 0.0 // Reset the total time

        // Mark audio as loading to prevent actions during this process
        isAudioLoading = true

        let session = URLSession(configuration: .default)
        let group = DispatchGroup()

        for url in urls {
            group.enter()
            session.downloadTask(with: url) { [weak self] localURL, _, error in
                defer { group.leave() } // Ensure group.leave is called
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

        // Notify once all audio files are loaded
        group.notify(queue: .main) {
            self.isAudioLoading = false // Audio finished loading
            print("All audio files are prepared.")
            self.playAudio() // Start fresh without trying to continue from the previous state
        }
    }

    /// Play audio from the current index.
    func playAudio() {
        guard !audioPlayers.isEmpty else {
            print("No audio loaded for playback.")
            return
        }
        guard currentAudioIndex < audioPlayers.count else {
            print("All audio files have been played.")
            return
        }

        let player = audioPlayers[currentAudioIndex]
        player.play()
        isPlaying = true
        startUpdatingProgress()
    }

    /// Stop all audio playback and reset the state.
    func stopAudio() {
        // Stop all audio players
        audioPlayers.forEach { $0.stop() }
        isPlaying = false

        // Invalidate and clear the progress timer if it's running
        timer?.invalidate()
        timer = nil
        currentTime = 0.0
        playCount = 0
        currentAudioIndex = 0
        
        // Reset the audio list
        resetAudioList() // Reset the audio URLs and players
    }
    func resetAudioList() {
        // Reset the audio list and players
        audioPlayers.removeAll()  // Clear the audio players
        audioURLs.removeAll()     // Clear the audio URLs
    }


    /// Seek to a specific time in the current audio track.
    func seekAudio(to time: TimeInterval) {
        guard !audioPlayers.isEmpty else { return }
        audioPlayers[currentAudioIndex].currentTime = time
    }

    /// Cycle the repeat count between 1 and 5.
    func cycleRepeatCount() {
        repeatCount = repeatCount % 5 + 1 // Cycles from 1 to 5
    }

    /// Handle when an audio player finishes playing.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if currentAudioIndex < audioPlayers.count - 1 {
            // Move to the next audio player if there are more
            currentAudioIndex += 1
            audioPlayers[currentAudioIndex].play()
        } else {
            // Cycle repeat if enabled
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

    /// Start updating the progress of the current audio track.
    private func startUpdatingProgress() {
        // Invalidate any existing timer before starting a new one
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    /// Update the current progress of the audio.
    private func updateProgress() {
        guard !audioPlayers.isEmpty else { return }
        let currentPlayer = audioPlayers[currentAudioIndex]
        if currentPlayer.isPlaying {
            currentTime = currentPlayer.currentTime
        }
    }
}

//class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
//    @Published var isPlaying = false
//    @Published var totalTime: TimeInterval = 0.0
//    @Published var currentTime: TimeInterval = 0.0
//    @Published var repeatCount = 1
//
//    private var playCount = 0
//    private var currentAudioIndex = 0
//    private var audioPlayers: [AVAudioPlayer] = []
//    private var audioURLs: [URL] = []  // Stores the list of audio URLs to play sequentially
//    private var timer: Timer?  // For updating progress
//
//    func loadAudio(urls: [URL]) {
//        // Stop any ongoing playback and reset
//        stopAudio()
//        audioPlayers.removeAll()
//        audioURLs = urls
//        currentAudioIndex = 0
//        playCount = 0
//
//        // Prepare audio players for all URLs
//        let session = URLSession(configuration: .default)
//        let group = DispatchGroup()
//
//        for url in urls {
//            group.enter()
//            session.downloadTask(with: url) { [weak self] localURL, _, error in
//                defer { group.leave() } // Always call leave to avoid deadlocks
//                guard let self = self, let localURL = localURL else {
//                    if let error = error {
//                        print("Error downloading audio: \(error.localizedDescription)")
//                    }
//                    return
//                }
//                do {
//                    let player = try AVAudioPlayer(contentsOf: localURL)
//                    player.delegate = self
//                    player.prepareToPlay()
//                    DispatchQueue.main.async {
//                        self.audioPlayers.append(player)
//                        // Update total time based on the first audio
//                        if self.audioPlayers.count == 1 {
//                            self.totalTime = player.duration
//                        }
//                    }
//                } catch {
//                    print("Error preparing audio for \(url): \(error.localizedDescription)")
//                }
//            }.resume()
//        }
//
//        group.notify(queue: .main) {
//            print("All audio files are prepared.")
//            if !self.audioPlayers.isEmpty {
//                self.playAudio() // Automatically start playback
//            }
//        }
//    }
//
//    func playAudio() {
//        guard !audioPlayers.isEmpty else {
//            print("No audio loaded for playback.")
//            return
//        }
//        guard currentAudioIndex < audioPlayers.count else {
//            print("All audio files have been played.")
//            return
//        }
//
//        let player = audioPlayers[currentAudioIndex]
//        player.play()
//        isPlaying = true
//        startUpdatingProgress()
//    }
//
//    func stopAudio() {
//        audioPlayers.forEach { $0.stop() }
//        isPlaying = false
//        timer?.invalidate()  // Stop the progress timer when audio is stopped
//        currentTime = 0.0
//    }
//
//    func seekAudio(to time: TimeInterval) {
//        guard !audioPlayers.isEmpty else { return }
//        audioPlayers[currentAudioIndex].currentTime = time
//    }
//
//    func cycleRepeatCount() {
//        repeatCount = repeatCount % 5 + 1 // Cycles from 1 to 5
//    }
//
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        if currentAudioIndex == 0 {
//            // After the first audio finishes, move to the second audio
//            currentAudioIndex = 1
//            audioPlayers[currentAudioIndex].play()
//        } else if currentAudioIndex < audioPlayers.count - 1 {
//            // Move to the next audio player if there are more
//            currentAudioIndex += 1
//            audioPlayers[currentAudioIndex].play()
//        } else {
//            // Cycle repeat if enabled
//            playCount += 1
//            if playCount < repeatCount {
//                currentAudioIndex = 0
//                audioPlayers[currentAudioIndex].play()
//            } else {
//                isPlaying = false
//                timer?.invalidate()  // Stop the progress timer when all files finish
//            }
//        }
//    }
//
//    private func startUpdatingProgress() {
//        // Invalidate any existing timer before starting a new one
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//            self?.updateProgress()
//        }
//        RunLoop.current.add(timer!, forMode: .common)
//    }
//
//    private func updateProgress() {
//        guard !audioPlayers.isEmpty else { return }
//        let currentPlayer = audioPlayers[currentAudioIndex]
//        if currentPlayer.isPlaying {
//            currentTime = currentPlayer.currentTime
//        }
//    }
//}


//DOWN below
//class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
//    @Published var isPlaying = false
//    @Published var totalTime: TimeInterval = 0.0
//    @Published var currentTime: TimeInterval = 0.0
//    @Published var repeatCount = 1
//
//    private var playCount = 0
//    private var currentAudioIndex = 0
//    private var audioPlayers: [AVAudioPlayer] = []
//    private var audioURLs: [URL] = []  // Stores the list of audio URLs to play sequentially
//    private var timer: Timer?  // For updating progress
//
//    func loadAudio(urls: [URL]) {
//        // Stop any ongoing playback and reset
//        stopAudio()
//        audioPlayers.removeAll()
//        audioURLs = urls
//        currentAudioIndex = 0
//        playCount = 0
//
//        // Prepare audio players for all URLs
//        let session = URLSession(configuration: .default)
//        let group = DispatchGroup()
//
//        urls.forEach { url in
//            group.enter()
//            session.downloadTask(with: url) { [weak self] localURL, _, error in
//                guard let self = self else { return }
//                if let localURL = localURL {
//                    do {
//                        let player = try AVAudioPlayer(contentsOf: localURL)
//                        player.delegate = self
//                        player.prepareToPlay()
//                        DispatchQueue.main.async {
//                            if self.audioPlayers.isEmpty { self.totalTime = player.duration }
//                        }
//                        self.audioPlayers.append(player)
//                    } catch {
//                        print("Error preparing audio for \(url): \(error.localizedDescription)")
//                    }
//                } else if let error = error {
//                    print("Error downloading audio: \(error.localizedDescription)")
//                }
//                group.leave()
//            }.resume()
//        }
//
//        group.notify(queue: .main) {
//            print("All audio files prepared.")
//        }
//    }
//
//    func playAudio() {
//        guard !audioPlayers.isEmpty else {
//            print("No audio loaded for playback.")
//            return
//        }
//        guard currentAudioIndex < audioPlayers.count else {
//            print("All audio files played.")
//            return
//        }
//        let player = audioPlayers[currentAudioIndex]
//        player.play()
//        isPlaying = true
//        startUpdatingProgress()
//    }
//
//    func stopAudio() {
//        audioPlayers.forEach { $0.stop() }
//        isPlaying = false
//        timer?.invalidate()  // Stop the progress timer when audio is stopped
//    }
//
//    func seekAudio(to time: TimeInterval) {
//        guard !audioPlayers.isEmpty else { return }
//        audioPlayers[currentAudioIndex].currentTime = time
//    }
//
//    func cycleRepeatCount() {
//        repeatCount = repeatCount % 5 + 1 // Cycles from 1 to 5
//    }
//
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        if currentAudioIndex < audioPlayers.count - 1 {
//            // Move to the next audio player
//            currentAudioIndex += 1
//            audioPlayers[currentAudioIndex].play()
//        } else {
//            // Cycle repeat if enabled
//            playCount += 1
//            if playCount < repeatCount {
//                currentAudioIndex = 0
//                audioPlayers[currentAudioIndex].play()
//            } else {
//                isPlaying = false
//                timer?.invalidate()  // Stop the progress timer when all files finish
//            }
//        }
//    }
//
//    private func startUpdatingProgress() {
//        // Invalidate any existing timer before starting a new one
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//            self?.updateProgress()
//        }
//        RunLoop.current.add(timer!, forMode: .common)
//    }
//
//    private func updateProgress() {
//        guard !audioPlayers.isEmpty else { return }
//        let currentPlayer = audioPlayers[currentAudioIndex]
//        if currentPlayer.isPlaying {
//            currentTime = currentPlayer.currentTime
//        }
//    }
//}
//UP Above
//class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
//    @Published var isPlaying = false
//    @Published var totalTime: TimeInterval = 0.0
//    @Published var currentTime: TimeInterval = 0.0
//    @Published var repeatCount = 1
//
//    private var playCount = 0
//    private var currentAudioIndex = 0
//    private var audioPlayers: [AVAudioPlayer] = []
//    private var audioURLs: [URL] = []  // Stores the list of audio URLs to play sequentially
//    private var timer: Timer?  // For updating progress
//
//    func loadAudio(urls: [URL]) {
//        // Stop any ongoing playback and reset
//        stopAudio()
//        audioPlayers.removeAll()
//        audioURLs = urls
//        currentAudioIndex = 0
//        playCount = 0
//
//        // Prepare audio players for all URLs
//        let session = URLSession(configuration: .default)
//        let group = DispatchGroup()
//
//        urls.forEach { url in
//            group.enter()
//            session.downloadTask(with: url) { [weak self] localURL, _, error in
//                guard let self = self else { return }
//                if let localURL = localURL {
//                    do {
//                        let player = try AVAudioPlayer(contentsOf: localURL)
//                        player.delegate = self
//                        player.prepareToPlay()
//                        DispatchQueue.main.async {
//                            if self.audioPlayers.isEmpty { self.totalTime = player.duration }
//                        }
//                        self.audioPlayers.append(player)
//                    } catch {
//                        print("Error preparing audio for \(url): \(error.localizedDescription)")
//                    }
//                } else if let error = error {
//                    print("Error downloading audio: \(error.localizedDescription)")
//                }
//                group.leave()
//            }.resume()
//        }
//
//        group.notify(queue: .main) {
//            print("All audio files prepared.")
//        }
//    }
//
//    func playAudio() {
//        guard !audioPlayers.isEmpty else {
//            print("No audio loaded for playback.")
//            return
//        }
//        guard currentAudioIndex < audioPlayers.count else {
//            print("All audio files played.")
//            return
//        }
//        let player = audioPlayers[currentAudioIndex]
//        player.play()
//        isPlaying = true
//        startUpdatingProgress()
//    }
//
//    func stopAudio() {
//        audioPlayers.forEach { $0.stop() }
//        isPlaying = false
//        timer?.invalidate()  // Stop the progress timer when audio is stopped
//    }
//
//    func seekAudio(to time: TimeInterval) {
//        guard !audioPlayers.isEmpty else { return }
//        audioPlayers[currentAudioIndex].currentTime = time
//    }
//
//    func cycleRepeatCount() {
//        repeatCount = repeatCount % 5 + 1 // Cycles from 1 to 5
//    }
//
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        if currentAudioIndex < audioPlayers.count - 1 {
//            // Move to the next audio player
//            currentAudioIndex += 1
//            audioPlayers[currentAudioIndex].play()
//        } else {
//            // Cycle repeat if enabled
//            playCount += 1
//            if playCount < repeatCount {
//                currentAudioIndex = 0
//                audioPlayers[currentAudioIndex].play()
//            } else {
//                isPlaying = false
//                timer?.invalidate()  // Stop the progress timer when all files finish
//            }
//        }
//    }
//
//    private func startUpdatingProgress() {
//        timer?.invalidate()  // Invalidate any existing timer before starting a new one
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//            self?.updateProgress()
//        }
//    }
//
//    private func updateProgress() {
//        guard !audioPlayers.isEmpty else { return }
//        currentTime = audioPlayers[currentAudioIndex].currentTime
//    }
//}

//class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
//    @Published var isPlaying = false
//    @Published var totalTime: TimeInterval = 0.0
//    @Published var currentTime: TimeInterval = 0.0
//    @Published var repeatCount = 1
//
//    private var playCount = 0
//    private var currentAudioIndex = 0
//    private var audioPlayers: [AVAudioPlayer] = []
//    private var audioURLs: [URL] = []  // Stores the list of audio URLs to play sequentially
//    private var timer: Timer?  // For updating progress
//
//    func loadAudio(urls: [URL]) {
//        // Stop any ongoing playback and reset
//        stopAudio()
//        audioPlayers.removeAll()
//        audioURLs = urls
//        currentAudioIndex = 0
//        playCount = 0
//
//        // Prepare audio players for all URLs
//        let session = URLSession(configuration: .default)
//        let group = DispatchGroup()
//
//        urls.forEach { url in
//            group.enter()
//            session.downloadTask(with: url) { [weak self] localURL, _, error in
//                guard let self = self else { return }
//                if let localURL = localURL {
//                    do {
//                        let player = try AVAudioPlayer(contentsOf: localURL)
//                        player.delegate = self
//                        player.prepareToPlay()
//                        DispatchQueue.main.async {
//                            if self.audioPlayers.isEmpty { self.totalTime = player.duration }
//                        }
//                        self.audioPlayers.append(player)
//                    } catch {
//                        print("Error preparing audio for \(url): \(error.localizedDescription)")
//                    }
//                } else if let error = error {
//                    print("Error downloading audio: \(error.localizedDescription)")
//                }
//                group.leave()
//            }.resume()
//        }
//
//        group.notify(queue: .main) {
//            print("All audio files prepared.")
//        }
//    }
//
//    func playAudio() {
//        guard !audioPlayers.isEmpty else {
//            print("No audio loaded for playback.")
//            return
//        }
//        guard currentAudioIndex < audioPlayers.count else {
//            print("All audio files played.")
//            return
//        }
//        let player = audioPlayers[currentAudioIndex]
//        player.play()
//        isPlaying = true
//        startUpdatingProgress()
//    }
//
//    func stopAudio() {
//        audioPlayers.forEach { $0.stop() }
//        isPlaying = false
//        timer?.invalidate()  // Stop the progress timer when audio is stopped
//    }
//
//    func seekAudio(to time: TimeInterval) {
//        guard !audioPlayers.isEmpty else { return }
//        audioPlayers[currentAudioIndex].currentTime = time
//    }
//
//    func cycleRepeatCount() {
//        repeatCount = repeatCount % 5 + 1 // Cycles from 1 to 5
//    }
//
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        if currentAudioIndex < audioPlayers.count - 1 {
//            // Move to the next audio player
//            currentAudioIndex += 1
//            audioPlayers[currentAudioIndex].play()
//        } else {
//            // Cycle repeat if enabled
//            playCount += 1
//            if playCount < repeatCount {
//                currentAudioIndex = 0
//                audioPlayers[currentAudioIndex].play()
//            } else {
//                isPlaying = false
//                timer?.invalidate()  // Stop the progress timer when all files finish
//            }
//        }
//    }
//
//    private func startUpdatingProgress() {
//        timer?.invalidate()  // Invalidate any existing timer before starting a new one
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//            self?.updateProgress()
//        }
//    }
//
//    private func updateProgress() {
//        guard !audioPlayers.isEmpty else { return }
//        currentTime = audioPlayers[currentAudioIndex].currentTime
//    }
//}



//class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
//    @Published var isPlaying = false
//    @Published var totalTime: TimeInterval = 0.0
//    @Published var currentTime: TimeInterval = 0.0
//    @Published var repeatCount = 1
//    private var playCount = 0
//    private var audioPlayer: AVAudioPlayer?
//    private var nextAudioPlayer: AVAudioPlayer?  // To play the second audio
//
//    var audioURL: URL? {
//        didSet {
//            setupAudio()
//        }
//    }
//
//    var nextAudioURL: URL?  // URL for the second audio
//
//    func setupAudio() {
//        guard let url = audioURL else {
//            print("Invalid audio URL")
//            return
//        }
//
//        let session = URLSession(configuration: .default)
//        let task = session.downloadTask(with: url) { [weak self] localURL, _, error in
//            guard let self = self else { return }
//            if let localURL = localURL {
//                do {
//                    self.audioPlayer = try AVAudioPlayer(contentsOf: localURL)
//                    self.audioPlayer?.delegate = self
//                    self.audioPlayer?.prepareToPlay()
//                    DispatchQueue.main.async {
//                        self.totalTime = self.audioPlayer?.duration ?? 0.0
//                    }
//                } catch {
//                    print("Error loading audio: \(error.localizedDescription)")
//                }
//            } else if let error = error {
//                print("Download error: \(error.localizedDescription)")
//            }
//        }
//        task.resume()
//
//        // If there’s a second audio URL (for the next audio), handle it
//        if let nextURL = nextAudioURL {
//            let nextTask = session.downloadTask(with: nextURL) { [weak self] localURL, _, error in
//                guard let self = self else { return }
//                if let localURL = localURL {
//                    do {
//                        self.nextAudioPlayer = try AVAudioPlayer(contentsOf: localURL)
//                        self.nextAudioPlayer?.delegate = self
//                        self.nextAudioPlayer?.prepareToPlay()
//                    } catch {
//                        print("Error loading next audio: \(error.localizedDescription)")
//                    }
//                } else if let error = error {
//                    print("Download error: \(error.localizedDescription)")
//                }
//            }
//            nextTask.resume()
//        }
//    }
//
//    func playAudio() {
//        guard let audioPlayer = audioPlayer else { return }
//        playCount = 0
//        audioPlayer.play()
//        isPlaying = true
//
//        // Once the first audio finishes, play the second
//        if let nextAudioPlayer = nextAudioPlayer {
//            nextAudioPlayer.play()
//        }
//    }
//
//    func stopAudio() {
//        audioPlayer?.pause()
//        nextAudioPlayer?.pause()
//        isPlaying = false
//    }
//
//    func seekAudio(to time: TimeInterval) {
//        audioPlayer?.currentTime = time
//        nextAudioPlayer?.currentTime = time
//    }
//
//    func updateProgress() {
//        guard let audioPlayer = audioPlayer else { return }
//        currentTime = audioPlayer.currentTime
//    }
//
//    func cycleRepeatCount() {
//        repeatCount = repeatCount % 5 + 1 // Cycles from 1 to 5
//    }
//
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        playCount += 1
//        if playCount < repeatCount {
//            player.currentTime = 0
//            player.play()
//        } else {
//            isPlaying = false
//        }
//    }
//}
//import AVFoundation
//
//class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
//    @Published var isPlaying = false
//    @Published var totalTime: TimeInterval = 0.0
//    @Published var currentTime: TimeInterval = 0.0
//    private var audioPlayer: AVAudioPlayer?
//
//    var audioURL: URL? {
//        didSet {
//            setupAudio()
//        }
//    }
//
//    var nextAudioURL: URL? // For combining audio
//
//    func setupAudio() {
//        guard let audioURL = audioURL else {
//            print("Invalid audio URL")
//            return
//        }
//
//        if let nextURL = nextAudioURL {
//            // Combine audio if nextAudioURL exists
//            combineAudioFiles(primaryURL: audioURL, nextURL: nextURL) { [weak self] combinedURL in
//                guard let self = self else { return }
//                self.audioPlayer = try? AVAudioPlayer(contentsOf: combinedURL)
//                self.audioPlayer?.prepareToPlay()
//                DispatchQueue.main.async {
//                    self.totalTime = self.audioPlayer?.duration ?? 0.0
//                }
//            }
//        } else {
//            // Load single audio file
//            loadAudio(from: audioURL)
//        }
//    }
//
//    private func loadAudio(from url: URL) {
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: url)
//            audioPlayer?.delegate = self
//            audioPlayer?.prepareToPlay()
//            DispatchQueue.main.async {
//                self.totalTime = self.audioPlayer?.duration ?? 0.0
//            }
//        } catch {
//            print("Error loading audio: \(error.localizedDescription)")
//        }
//    }
//
//    private func combineAudioFiles(primaryURL: URL, nextURL: URL, completion: @escaping (URL) -> Void) {
//        let composition = AVMutableComposition()
//
//        do {
//            let primaryAsset = AVURLAsset(url: primaryURL)
//            let nextAsset = AVURLAsset(url: nextURL)
//
//            guard let primaryTrack = primaryAsset.tracks(withMediaType: .audio).first,
//                  let nextTrack = nextAsset.tracks(withMediaType: .audio).first else {
//                print("Failed to load tracks.")
//                return
//            }
//
//            let primaryCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
//            let nextCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
//
//            try primaryCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: primaryAsset.duration), of: primaryTrack, at: .zero)
//            try nextCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: nextAsset.duration), of: nextTrack, at: primaryAsset.duration)
//
//            let exportURL = FileManager.default.temporaryDirectory.appendingPathComponent("combinedAudio.m4a")
//            if FileManager.default.fileExists(atPath: exportURL.path) {
//                try FileManager.default.removeItem(at: exportURL)
//            }
//
//            let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
//            exporter?.outputURL = exportURL
//            exporter?.outputFileType = .m4a
//            exporter?.exportAsynchronously {
//                if exporter?.status == .completed {
//                    completion(exportURL)
//                } else if let error = exporter?.error {
//                    print("Export failed: \(error.localizedDescription)")
//                }
//            }
//        } catch {
//            print("Error combining audio: \(error.localizedDescription)")
//        }
//    }
//
//    func playAudio() {
//        audioPlayer?.play()
//        isPlaying = true
//    }
//
//    func stopAudio() {
//        audioPlayer?.stop()
//        isPlaying = false
//    }
//
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        isPlaying = false
//    }
//}
