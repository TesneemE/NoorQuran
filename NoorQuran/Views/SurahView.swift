
import SwiftUI
import AVFoundation

struct SurahView: View {
    @ObservedObject var surahStore = SurahStore()
    @State private var surahDetail: SurahDetail?
    @State private var searchTerm: String = ""
    @State private var isAudioPlayerVisible = false
    @EnvironmentObject var audioManager: AudioManager
    let surahNumber: Int
    @EnvironmentObject var memorizationStore: MemorizationStore
    @EnvironmentObject var bookmarkAyahStore: BookmarkAyahStore

    var body: some View {
        NavigationStack {
            ZStack {
                // Entire background color
                LinearGradient(gradient: Gradient(colors: [Color("Green"), Color("AccentGreen")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)

                VStack {
                    // surah hader Section
                    if let surahDetail = surahDetail {
                        VStack(spacing: 8) {
                            Text(surahDetail.englishName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("(\(surahDetail.englishNameTranslation))")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
//                        .background(Color("Green").opacity(0.6)) // Header background
                        .cornerRadius(15)
                        .padding(.horizontal)

                        TextField("Search Ayah...(1-\(surahDetail.numberOfAyahs))", text: $searchTerm)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .keyboardType(.numberPad)

                        // for scrolling Ayah List
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 10) {
                                    ForEach(surahDetail.ayahs) { ayah in
                                        VStack(alignment: .leading) {
                                            NavigationLink(destination: AyahDetailView(ayah: ayah, surahDetail: surahDetail)) {
                                                HStack {
                                                    Text("\(ayah.numberInSurah).")
                                                    Spacer()
                                                    Text(ayah.text)
                                                        .font(.title2)
                                                        .foregroundColor(.black)

                                                }
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color("AccentGreen")) // Background for ayah
                                                        .shadow(radius: 5)
                                                )
                                                .padding(.horizontal)
                                                .contentShape(Rectangle())
                                            }
                                            .padding(.top)

                                            HStack {
                                                PlayButton(surahStore: surahStore, surahDetail: surahDetail, ayah: ayah, isAudioPlayerVisible: $isAudioPlayerVisible)
                                                    .environmentObject(audioManager)

                                                Spacer()

                                                Button(action: {
                                                    let surahName = surahDetail.englishName
                                                    let text = ayah.text
                                                    let bookmarkedAyah = BookmarkedAyah(
                                                        surah: surahDetail.number,
                                                        surahName: surahName,
                                                        ayah: ayah.numberInSurah,
                                                        text: text
                                                    )
                                                    bookmarkAyahStore.toggleBookmark(for: bookmarkedAyah)
                                                }) {
                                                    Image(systemName: bookmarkAyahStore.isBookmarked(surah: surahDetail.number, ayah: ayah.numberInSurah) ? "bookmark.fill" : "bookmark")
                                                        .foregroundColor(bookmarkAyahStore.isBookmarked(surah: surahDetail.number, ayah: ayah.numberInSurah) ? Color("Pink") : .gray)
                                                }

                                                Button(action: {
                                                    let surahName = surahDetail.englishName
                                                    let memorizedAyah = MemorizedAyah(
                                                        surah: surahDetail.number,
                                                        surahName: surahName,
                                                        ayah: ayah.numberInSurah,
                                                        dateMemorized: Date()
                                                    )
                                                    memorizationStore.toggleMemorization(for: memorizedAyah)
                                                }) {
                                                    Image(systemName: "checkmark.seal")
                                                        .foregroundColor(memorizationStore.isMemorized(surah: surahDetail.number, ayah: ayah.numberInSurah) ? Color("Pink") : .gray)
                                                }
                                            }
                                            .padding()
                                            .background(Color("AccentPink"))
                                            .cornerRadius(10)
                                            .padding(.horizontal)
                                        }
                                        .background(Color("Green").opacity(0.2)) // ayah item background part
                                        .id(ayah.numberInSurah)
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .background(Color("Green").opacity(0.4)) // back for the scrollview
                            .onChange(of: searchTerm) { newValue in
                                if let targetNumber = Int(newValue), surahDetail.ayahs.contains(where: { $0.numberInSurah == targetNumber }) {
                                    withAnimation {
                                        proxy.scrollTo(targetNumber, anchor: .center)
                                    }
                                }
                            }
                        }
                        .padding(.top, 10)
                    } else {
                        ProgressView("Loading Surah Details...")
                            .foregroundColor(.white)
                    }
                }
                .onAppear {
                    audioManager.stopAudio()
                    surahStore.fetchSurahDetail(surahNumber: surahNumber) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let detail):
                                self.surahDetail = detail
                            case .failure(let error):
                                print("Failed to fetch Surah detail:", error.localizedDescription)
                            }
                        }
                    }
                }
//                .onDisappear {
//                    audioManager.stopAudio()
//                }
                .navigationTitle(surahDetail?.name ?? "Loading...")
                   .navigationBarTitleDisplayMode(.inline)               .foregroundColor(.gray)

                // audio player section
                if isAudioPlayerVisible {
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            AudioPlayerView()
                                .environmentObject(audioManager)
                                .frame(width: geometry.size.width, height: 200)
                                .background(Color("Green").opacity(0.4))
                                .cornerRadius(20)
                                .shadow(radius: 5)
                                .transition(.move(edge: .bottom))
                        }
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .background(
                        Color.black.opacity(0.2)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation {
                                    isAudioPlayerVisible.toggle()
                                }
                            }
                    )
                }
            }
        }
    }
}

struct SurahView_Previews: PreviewProvider {
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
        SurahView(surahNumber: 1)
            .environmentObject(bookmarkStore)
            .environmentObject(store)
            .environmentObject(mockAudioManager)

        
    }
}
    

