//
//  AyaView.swift
//  NoorQuran
//
//  Created by Tes Essa on 10/17/24.
//

//import SwiftUI
//
//
//
//struct AyaView: View {
//    let surah: Surah
//    let verseNumber: Int
//
//    var body: some View {
//        VStack {
//            Text(surah.englishName)
//                .font(.title)
//                .padding(.bottom, 10)
//            Text("Verse \(verseNumber)")
//                .font(.headline)
//            Text("[Aya content here]")
//                .padding()
//        }
//        .navigationTitle("Verse \(verseNumber)")
//    }
//}
//
//
//struct AyaView_Previews: PreviewProvider {
//    static var previews: some View {
//        let surah_test = Surah(number: 1, name:"سُورَةُ ٱلْفَاتِحَةِ", englishName: "Al-Fatiha", englishNameTranslation: "The Opening", revelationType: "Meccan", numberOfAyahs: 7)
//        AyaView(surah: surah_test, verseNumber:1)
//    }
//}

//import SwiftUI
//enum NavigationState {
//    case none
//    case ayahDetail(Ayah)
//}
//
//
//struct SurahView: View {
//    @ObservedObject var surahStore = SurahStore() // Store to fetch surah data
//    @State private var surahDetail: SurahDetail? // Store for fetched surah details
//    @State private var searchTerm: String = "" // Search term for Ayah number
//    @State private var isAudioPlayerVisible = false // Controls the visibility of the audio player
//    @StateObject private var audioManager = AudioManager() // Audio Manager to handle audio playback
//    let surahNumber: Int // Surah number passed from the previous view
//    let firstAyahAudioURL = "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3" // Default URL for first Ayah audio
//    @State private var navigationState: NavigationState = .none
//    @State private var selectedAyah: Ayah? // Store for the selected Ayah
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                if let surahDetail = surahDetail {
//                    // Display Surah details
//                    Text("Surah: \(surahDetail.englishName) (\(surahDetail.englishNameTranslation))")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.primary)
//                        .padding()
//                        .multilineTextAlignment(.center)
//                    
//                    // Search bar to search for Ayahs by number
//                    TextField("Search Ayah...(1-\(surahDetail.numberOfAyahs))", text: $searchTerm)
//                        .padding()
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding(.horizontal)
//                        .keyboardType(.numberPad)
//                    
//                    ScrollViewReader { proxy in
//                        List(surahDetail.ayahs) { ayah in
//                            VStack {
//                                Button(action: {
//                                    // Set the selected Ayah and navigate to its detail view
//                                    navigateToAyahDetailView(for: ayah, surahDetail: surahDetail)
//                                }) {
//                                    VStack(alignment: .leading) {
//                                        HStack {
//                                            Text("\(ayah.numberInSurah).")
//                                            Spacer()
//                                            Text(ayah.text)
//                                                .font(.title3)
//                                                .foregroundColor(.primary)
//                                        }
//                                        .padding()
//                                    }
//                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
//                                    .padding(.horizontal)
//                                }
//                                .buttonStyle(PlainButtonStyle()) // Prevent default button style interference
//                                
//                                // Button Section for Play, Bookmark, and Memorize actions
//                                HStack {
//                                    PlayButton(surahStore: surahStore, audioManager: audioManager, surahDetail: surahDetail, ayah: ayah, isAudioPlayerVisible: $isAudioPlayerVisible)
//                                    
//                                    Spacer()
//                                    
//                                    Button(action: {
//                                        // Bookmark action
//                                    }) {
//                                        Image(systemName: "bookmark")
//                                            .font(.title2)
//                                            .foregroundColor(.orange)
//                                    }
//                                    
//                                    Button(action: {
//                                        // Memorize action
//                                    }) {
//                                        Image(systemName: "checkmark.seal")
//                                            .font(.title2)
//                                            .foregroundColor(.green)
//                                    }
//                                }
//                                .padding()
//                                .background(Color.gray.opacity(0.1)) // Background color for the button section
//                                .cornerRadius(10)
//                                .padding(.horizontal)
//                            }
//                            .id(ayah.numberInSurah)
//                        }
//                        .onChange(of: searchTerm) { newValue in
//                            if let targetNumber = Int(newValue), surahDetail.ayahs.contains(where: { $0.numberInSurah == targetNumber }) {
//                                withAnimation {
//                                    proxy.scrollTo(targetNumber, anchor: .center)
//                                }
//                            }
//                        }
//                    }
//                }
//                else {
//                    ProgressView("Loading Surah Details...")
//                }
//            }
//            .onAppear {
//                surahStore.fetchSurahDetail(surahNumber: surahNumber) { result in
//                    DispatchQueue.main.async {
//                        switch result {
//                        case .success(let detail):
//                            self.surahDetail = detail
//                        case .failure(let error):
//                            print("Failed to fetch Surah detail:", error.localizedDescription)
//                        }
//                    }
//                }
//            }
//            .navigationBarTitle(surahDetail?.name ?? "Loading...", displayMode: .inline)
//            .background(
//                NavigationLink(
//                    destination: AyahDetailView(ayah: selectedAyah ?? Ayah(number: 0, text: "Loading...", numberInSurah: 0), surahDetail: surahDetail ?? SurahDetail(number: 0, name: "Loading...", englishName:"Loading...", englishNameTranslation:"Loading...", numberOfAyahs: 0, revelationType: "Loading...", ayahs: [Ayah] )),
//                    isActive: Binding(
//                        get: { navigationState == .ayahDetail(selectedAyah ?? Ayah(number: 0, text: "Loading...", numberInSurah: 0)) },
//                        set: { if !$0 { navigationState = .none } }
//                    )
//                ) {
//                    EmptyView()
//                }
//            )
//        }
//        .overlay(
//            Group {
//                if isAudioPlayerVisible {
//                    GeometryReader { geometry in
//                        VStack {
//                            Spacer()
//                            AudioPlayerView(audioManager: audioManager)
//                                .frame(width: geometry.size.width, height: 200)
//                                .background(Color.white)
//                                .cornerRadius(20)
//                                .shadow(radius: 5)
//                                .transition(.move(edge: .bottom))
//                        }
//                    }
//                    .edgesIgnoringSafeArea(.bottom)
//                    .background(
//                        Color.black.opacity(0.5)
//                            .edgesIgnoringSafeArea(.all)
//                            .onTapGesture {
//                                withAnimation {
//                                    isAudioPlayerVisible.toggle() // Hide audio player
//                                }
//                            }
//                    )
//                }
//            }
//        )
//    }
//
//    private func navigateToAyahDetailView(for ayah: Ayah, surahDetail: SurahDetail) {
//        // Set the selected Ayah and update navigation state to navigate
//        selectedAyah = ayah
//        navigationState = .ayahDetail(ayah)
//    }
//}

//Struct SurahDetailView: View {
//    @State private var searchTerm = ""
//    @State private var isAudioPlayerVisible = false
//    @ObservedObject var audioManager: AudioManager // Assuming an AudioManager object that handles the audio
//    var surahDetail: SurahDetail?
//
//    var body: some View {
//        ZStack {
//            // Main content (e.g., Surah details and list of Ayahs)
//            VStack {
//                if let surahDetail = surahDetail {
//                    Text("Surah: \(surahDetail.englishName)")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.primary)
//                        .padding()
//                    TextField("Search Ayah...", text: $searchTerm)
//                        .padding()
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    
//                    List(surahDetail.ayahs) { ayah in
//                        VStack {
//                            NavigationLink(destination: AyahDetailView(ayah: ayah)) {
//                                HStack {
//                                    Text("\(ayah.numberInSurah).")
//                                    Spacer()
//                                    Text(ayah.text)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//
//            // Audio player overlay
//            if isAudioPlayerVisible {
//                GeometryReader { geometry in
//                    VStack {
//                        Spacer()
//                        AudioPlayerView(audioManager: audioManager)
//                            .frame(width: geometry.size.width, height: 200)
//                            .background(Color.white)
//                            .cornerRadius(20)
//                            .shadow(radius: 5)
//                            .transition(.move(edge: .bottom))
//                    }
//                }
//                .edgesIgnoringSafeArea(.bottom)
//                .background(
//                    Color.black.opacity(0.5)
//                        .edgesIgnoringSafeArea(.all)
//                        .onTapGesture {
//                            withAnimation {
//                                isAudioPlayerVisible.toggle()
//                            }
//                        }
//                )
//            }
//        }
//        .onAppear {
//            // Initial setup or loading
//        }
//    }
//}



//import SwiftUI
//enum NavigationState {
//    case none
//    case ayahDetail(Ayah)
//}
//struct SurahView: View {
//    @ObservedObject var surahStore = SurahStore() // Store to fetch surah data
//    @State private var surahDetail: SurahDetail? // Store for fetched surah details
//    @State private var searchTerm: String = "" // Search term for Ayah number
//    @State private var isAudioPlayerVisible = false // Controls the visibility of the audio player
//    @StateObject private var audioManager = AudioManager() // Audio Manager to handle audio playback
//    let surahNumber: Int // Surah number passed from the previous view
//    let firstAyahAudioURL = "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3" // Default URL for first Ayah audio
//    @State private var navigationState: NavigationState = .none
//    var body: some View {
//        NavigationView {
//            VStack {
//                if let surahDetail = surahDetail {
//                    // Display Surah details
//                    Text("Surah: \(surahDetail.englishName) (\(surahDetail.englishNameTranslation))")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.primary)
//                        .padding()
//                        .multilineTextAlignment(.center)
//                    
//                    // Search bar to search for Ayahs by number
//                    TextField("Search Ayah...(1-\(surahDetail.numberOfAyahs))", text: $searchTerm)
//                        .padding()
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding(.horizontal)
//                        .keyboardType(.numberPad)
//                    
//                    ScrollViewReader { proxy in
//                        List(surahDetail.ayahs) { ayah in
////                            VStack {
////                                NavigationLink(destination: AyahDetailView(ayah: ayah, surahDetail: surahDetail)) {
////                                    VStack(alignment: .leading) {
////                                        HStack {
////                                            Text("\(ayah.numberInSurah).")
////                                            Spacer()
////                                            Text(ayah.text)
////                                                .font(.title3)
////                                                .foregroundColor(.primary)
////                                        }
////                                        .padding()
////                                    }
////                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
////                                    .padding(.horizontal)
////                                }
////                                .buttonStyle(PlainButtonStyle()) // Prevent default button style appearance on tap
//                            VStack {
//                                HStack {
//                                    // Only this part is tappable to navigate
//                                    NavigationLink(destination: AyahDetailView(ayah: ayah, surahDetail: surahDetail)) {
//                                        VStack(alignment: .leading) {
//                                            HStack {
//                                                Text("\(ayah.numberInSurah).")
//                                                Spacer()
//                                                Text(ayah.text)
//                                                    .font(.title3)
//                                                    .foregroundColor(.primary)
//                                            }
//                                            .padding()
//                                        }
//                                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
//                                        .padding(.horizontal)
//                                    }
//                                    .buttonStyle(PlainButtonStyle()) // Prevents button style interference
//                                }
//                                // Button Section for Play, Bookmark, and Memorize actions
//                                HStack {
//                                    PlayButton(surahStore: surahStore, audioManager: audioManager, surahDetail: surahDetail, ayah: ayah, isAudioPlayerVisible: $isAudioPlayerVisible)
//                                    
//                                    
//                                    Spacer()
//                                    
//                                    Button(action: {
//                                        // Bookmark action
//                                    }) {
//                                        Image(systemName: "bookmark")
//                                            .font(.title2)
//                                            .foregroundColor(.orange)
//                                    }
//                                    
//                                    Button(action: {
//                                        // Memorize action
//                                    }) {
//                                        Image(systemName: "checkmark.seal")
//                                            .font(.title2)
//                                            .foregroundColor(.green)
//                                    }
//                                }
//                                .padding()
//                                .background(Color.gray.opacity(0.1)) // Background color for the button section
//                                .cornerRadius(10)
//                                .padding(.horizontal)
//                            }
//                            .id(ayah.numberInSurah)
//                        }
//                        .onChange(of: searchTerm) { newValue in
//                            if let targetNumber = Int(newValue), surahDetail.ayahs.contains(where: { $0.numberInSurah == targetNumber }) {
//                                withAnimation {
//                                    proxy.scrollTo(targetNumber, anchor: .center)
//                                }
//                            }
//                        }
//                    }
//                }
//                else {
//                    ProgressView("Loading Surah Details...")
//                }
//            }
//            .onAppear {
//                surahStore.fetchSurahDetail(surahNumber: surahNumber) { result in
//                    DispatchQueue.main.async {
//                        switch result {
//                        case .success(let detail):
//                            self.surahDetail = detail
//                        case .failure(let error):
//                            print("Failed to fetch Surah detail:", error.localizedDescription)
//                        }
//                    }
//                }
//            }
//            .navigationBarTitle(surahDetail?.name ?? "Loading...", displayMode: .inline)
//        }
//        .overlay(
//            Group {
//                if isAudioPlayerVisible {
//                    GeometryReader { geometry in
//                        VStack {
//                            Spacer()
//                            AudioPlayerView(audioManager: audioManager)
//                                .frame(width: geometry.size.width, height: 200)
//                                .background(Color.white)
//                                .cornerRadius(20)
//                                .shadow(radius: 5)
//                                .transition(.move(edge: .bottom))
//                        }
//                    }
//                    .edgesIgnoringSafeArea(.bottom)
//                    .background(
//                        Color.black.opacity(0.5)
//                            .edgesIgnoringSafeArea(.all)
//                            .onTapGesture {
//                                withAnimation {
//                                    isAudioPlayerVisible.toggle() // Hide audio player
//                                }
//                            }
//                    )
//                }
//            }
//        )
//    }
//}




//                            VStack {
//                                NavigationLink(destination: AyahDetailView(ayah: ayah, surahDetail: surahDetail)) {
//                                    VStack(alignment: .leading) {
//                                        HStack {
//                                            Text("\(ayah.numberInSurah).")
//                                            Spacer()
//                                            Text(ayah.text)
//                                                .font(.title3)
//                                                .foregroundColor(.primary)
//                                        }
//                                        .padding()
//                                    }
//                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
//                                    .padding(.horizontal)
//                                }
//                                .buttonStyle(PlainButtonStyle()) // Prevent default button style appearance on tap
