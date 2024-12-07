
import SwiftUI
//enum NavigationState {
//    case none
//    case navigateToDetail
//}
//enum NavigationTarget: Hashable {
//    case detailView
//}
struct SurahView: View {
    @ObservedObject var surahStore = SurahStore() // Store to fetch surah data
    @State private var surahDetail: SurahDetail? // Store for fetched surah details
    @State private var searchTerm: String = "" // Search term for Ayah number
    @State private var isAudioPlayerVisible = false // Controls the visibility of the audio player
    @StateObject private var audioManager = AudioManager() // Audio Manager to handle audio playback
    let surahNumber: Int // Surah number passed from the previous view
    let firstAyahAudioURL = "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3" // Default URL for first Ayah audio
    @EnvironmentObject var memorizationStore: MemorizationStore
    @EnvironmentObject var bookmarkAyahStore: BookmarkAyahStore
    
    var body: some View {
        NavigationView {
            VStack {
                if let surahDetail = surahDetail {
                    // Display Surah details
                    Text("Surah: \(surahDetail.englishName) (\(surahDetail.englishNameTranslation))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    // Search bar to search for Ayahs by number
                    TextField("Search Ayah...(1-\(surahDetail.numberOfAyahs))", text: $searchTerm)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .keyboardType(.numberPad)
                    
                    ScrollViewReader { proxy in
                        List(surahDetail.ayahs) { ayah in
                            VStack(alignment: .leading) {
                                
                                NavigationLink(destination: AyahDetailView(ayah: ayah, surahDetail: surahDetail)) {
                                    HStack {
                                        Text("\(ayah.numberInSurah).")
                                        Spacer()
                                        Text(ayah.text)
                                            .font(.title3)
                                            .foregroundColor(.primary)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white)
                                            .shadow(radius: 5)
                                    )
                                    .padding(.horizontal)
                                    .contentShape(Rectangle())
                                }
                                
                                // Button Section for Play, Bookmark, and Memorize actions
                                HStack {
                                    PlayButton(surahStore: surahStore, audioManager: audioManager, surahDetail: surahDetail, ayah: ayah, isAudioPlayerVisible: $isAudioPlayerVisible)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        guard ayah.numberInSurah > 0 else {
                                            print("Invalid Ayah number: \(ayah.numberInSurah)")
                                            return
                                        }
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
                                            .foregroundColor(bookmarkAyahStore.isBookmarked(surah: surahDetail.number, ayah: ayah.numberInSurah) ? .green : .gray)
                                    }
                                    
                                    Button(action: {
                                        guard ayah.numberInSurah > 0 else {
                                            print("Invalid Ayah number: \(ayah.numberInSurah)")
                                            return
                                        }
                                        let surahName = surahDetail.englishName
                                        let memorizedAyah = MemorizedAyah(
                                            surah: surahDetail.number,
                                            surahName: surahName,
                                            ayah: ayah.numberInSurah,
                                            dateMemorized: Date()
                                        )
                                        memorizationStore.toggleMemorization(for: memorizedAyah)
                                    }) {
                                        Image(systemName: memorizationStore.isMemorized(surah: surahDetail.number, ayah: ayah.numberInSurah) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(memorizationStore.isMemorized(surah: surahDetail.number, ayah: ayah.numberInSurah) ? .green : .gray)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                            .id(ayah.numberInSurah)
                            .buttonStyle(PlainButtonStyle())
                        }
                        .onChange(of: searchTerm) { newValue in
                            if let targetNumber = Int(newValue), surahDetail.ayahs.contains(where: { $0.numberInSurah == targetNumber }) {
                                withAnimation {
                                    proxy.scrollTo(targetNumber, anchor: .center)
                                }
                            }
                        }
                    }
                }
                else {
                    ProgressView("Loading Surah Details...")
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
            .onDisappear {
                // Stop and reset the audio manager when the view disappears
                audioManager.stopAudio()
            }
            .navigationBarTitle(surahDetail?.name ?? "Loading...", displayMode: .inline)
        }
        .overlay(
            Group {
                if isAudioPlayerVisible {
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            AudioPlayerView(audioManager: audioManager)
                                .frame(width: geometry.size.width, height: 200)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                                .transition(.move(edge: .bottom))
                        }
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .background(
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation {
                                    isAudioPlayerVisible.toggle() // Hide audio player
                                }
                            }
                    )
                }
            }
        )
    }
}

//
//var body: some View {
//    NavigationView {
//        VStack {
//            if let surahDetail = surahDetail {
//                // Display Surah details
//                Text("Surah: \(surahDetail.englishName) (\(surahDetail.englishNameTranslation))")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.primary)
//                    .padding()
//                    .multilineTextAlignment(.center)
//
//                // Search bar to search for Ayahs by number
//                TextField("Search Ayah...(1-\(surahDetail.numberOfAyahs))", text: $searchTerm)
//                    .padding()
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                    .keyboardType(.numberPad)
//
//                ScrollViewReader { proxy in
//                    List(surahDetail.ayahs) { ayah in
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
//                        VStack {
//                            HStack {
//                                // Only this part is tappable to navigate
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
//                                .buttonStyle(PlainButtonStyle()) // Prevents button style interference
//                            }
//                            // Button Section for Play, Bookmark, and Memorize actions
//                            HStack {
//                                PlayButton(surahStore: surahStore, audioManager: audioManager, surahDetail: surahDetail, ayah: ayah, isAudioPlayerVisible: $isAudioPlayerVisible)
//
//
//                                Spacer()
//
//                                Button(action: {
//                                    // Bookmark action
//                                }) {
//                                    Image(systemName: "bookmark")
//                                        .font(.title2)
//                                        .foregroundColor(.orange)
//                                }
//
//                                Button(action: {
//                                    // Memorize action
//                                }) {
//                                    Image(systemName: "checkmark.seal")
//                                        .font(.title2)
//                                        .foregroundColor(.green)
//                                }
//                            }
//                            .padding()
//                            .background(Color.gray.opacity(0.1)) // Background color for the button section
//                            .cornerRadius(10)
//                            .padding(.horizontal)
//                        }
//                        .id(ayah.numberInSurah)
//                    }
//                    .onChange(of: searchTerm) { newValue in
//                        if let targetNumber = Int(newValue), surahDetail.ayahs.contains(where: { $0.numberInSurah == targetNumber }) {
//                            withAnimation {
//                                proxy.scrollTo(targetNumber, anchor: .center)
//                            }
//                        }
//                    }
//                }
//            }
//            else {
//                ProgressView("Loading Surah Details...")
//            }
//        }
//        .onAppear {
//            surahStore.fetchSurahDetail(surahNumber: surahNumber) { result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let detail):
//                        self.surahDetail = detail
//                    case .failure(let error):
//                        print("Failed to fetch Surah detail:", error.localizedDescription)
//                    }
//                }
//            }
//        }
//        .navigationBarTitle(surahDetail?.name ?? "Loading...", displayMode: .inline)
//    }
//    .overlay(
//        Group {
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
//                                isAudioPlayerVisible.toggle() // Hide audio player
//                            }
//                        }
//                )
//            }
//        }
//    )
//}

//struct SurahView: View {
//    @ObservedObject var surahStore = SurahStore() // Assuming this fetches Surah details
//    @State private var surahDetail: SurahDetail?
//    @State private var searchTerm: String = ""
//    @State private var isAudioPlayerVisible = false // Controls the visibility of the audio player
//    @StateObject private var audioManager = AudioManager()
//    let surahNumber: Int
//    let firstAyahAudioURL = "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3"
//
//
//
//    var body: some View {
//        VStack {
//            if let surahDetail = surahDetail {
//                // Surah Title and Search Field
//                Text("Surah: \(surahDetail.englishName) (\(surahDetail.englishNameTranslation))")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.primary)
//                    .padding()
//                    .multilineTextAlignment(.center)
//
//                TextField("Search Ayah...(1-\(surahDetail.numberOfAyahs))", text: $searchTerm)
//                    .padding()
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                    .keyboardType(.numberPad)
//
//                // List of Ayahs with Audio Buttons
//                ScrollViewReader { proxy in
//                    List(surahDetail.ayahs) { ayah in
//                        VStack(alignment: .leading) {
//                            HStack {
//                                Text("\(ayah.numberInSurah).")
//                                Spacer()
//                                Text(ayah.text)
//                                    .font(.title3)
//                                    .foregroundColor(.primary)
//                            }
//
//                            HStack {
//                                Button(action: {
//                                    surahStore.fetchAyahAudioUrl(surahNumber: surahDetail.number, ayahNumber: ayah.numberInSurah) { result in
//                                        DispatchQueue.main.async {
//                                            switch result {
//                                            case .success(let audioUrl):
//                                                // Check if this is the first Ayah in the Surah, but not Surah 1 or 9
//                                                if ayah.numberInSurah == 1 && surahDetail.number != 1 && surahDetail.number != 9 {
//                                                    if let firstAyahURL = URL(string: firstAyahAudioURL),
//                                                       let ayahAudioURL = ayah.audio, let ayahURL = URL(string: ayahAudioURL) {
//                                                        audioManager.loadAudio(urls: [firstAyahURL, ayahURL])
//                                                    }
//                                                }
//                                                else{
//                                                    if let ayahAudioURL = ayah.audio, let url = URL(string: ayahAudioURL) {
//                                                        audioManager.loadAudio(urls: [url]) // Update the AudioManager with the selected Ayah's audio
//                                                    }
//                                                }
//                                                withAnimation {
//                                                    isAudioPlayerVisible.toggle() // Show the audio player
//                                                }
//                                            case .failure(let error):
//                                                print("Failed to fetch audio URL:", error.localizedDescription)
//                                            }
//                                        }
//                                    }
//                                }) {
//                                    Image(systemName: "play.circle.fill")
//                                        .font(.title2)
//                                        .foregroundColor(.blue)
//                                }
//
//
//                                .padding(.leading, 10)
//
//                                Button(action: {
//                                    // Bookmark logic
//                                }) {
//                                    Image(systemName: "bookmark")
//                                        .font(.title2)
//                                        .foregroundColor(.orange)
//                                }
//
//                                Button(action: {
//                                    // Memorize logic
//                                }) {
//                                    Image(systemName: "checkmark.seal")
//                                        .font(.title2)
//                                        .foregroundColor(.green)
//                                }
//                            }
//                        }
//                        .padding()
//                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
//                        .padding(.horizontal)
//                        .id(ayah.numberInSurah) // Unique ID for scrolling
//                    }
//                    .onChange(of: searchTerm) { newValue in
//                        if let targetNumber = Int(newValue), surahDetail.ayahs.contains(where: { $0.numberInSurah == targetNumber }) {
//                            withAnimation {
//                                proxy.scrollTo(targetNumber, anchor: .center)
//                            }
//                        }
//                    }
//                }
//            } else {
//                ProgressView("Loading Surah Details...")
//            }
//        }
//        .onAppear {
//               surahStore.fetchSurahDetail(for: surahNumber) { result in
//                   DispatchQueue.main.async {
//                       switch result {
//                       case .success(let detail):
//                           self.surahDetail = detail // Set the SurahDetail state with the fetched data
//                       case .failure(let error):
//                           print("Failed to fetch Surah detail:", error.localizedDescription)
//                       }
//                   }
//               }
//           }
//        .navigationBarTitle(surahDetail.englishName, displayMode: .inline)
//
//                    // Audio Player
//                    if isAudioPlayerVisible {
//                        GeometryReader { geometry in
//                            VStack {
//                                Spacer()
//                                AudioPlayerView(audioManager: audioManager)
//                                    .frame(width: geometry.size.width, height: 200)
//                                    .background(Color.white)
//                                    .cornerRadius(20)
//                                    .shadow(radius: 5)
//                                    .transition(.move(edge: .bottom)) // Slide in/out animation
//                            }
//                        }
//                        .edgesIgnoringSafeArea(.bottom)
//                        .background(
//                            Color.black.opacity(0.5)
//                                .edgesIgnoringSafeArea(.all)
//                                .onTapGesture {
//                                    withAnimation {
//                                        isAudioPlayerVisible.toggle() // Hide audio player
//                                    }
//                                }
//                        )
//                    }
//                }
//            }
//        }


//LAST WORKING ONE
//struct SurahView: View {
//    @ObservedObject var surahStore = SurahStore() // Store to fetch surah data
//    @State private var surahDetail: SurahDetail? // Store for fetched surah details
//    @State private var searchTerm: String = "" // Search term for Ayah number
//    @State private var isAudioPlayerVisible = false // Controls the visibility of the audio player
//    @StateObject private var audioManager = AudioManager() // Audio Manager to handle audio playback
//    let surahNumber: Int // Surah number passed from the previous view
//    let firstAyahAudioURL = "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3" // Default URL for first Ayah audio
//
//    var body: some View {
//        VStack {
//            if let surahDetail = surahDetail {
//                // Display Surah details
//                Text("Surah: \(surahDetail.englishName) (\(surahDetail.englishNameTranslation))")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.primary)
//                    .padding()
//                    .multilineTextAlignment(.center)
//
//                // Search bar to search for Ayahs by number
//                TextField("Search Ayah...(1-\(surahDetail.numberOfAyahs))", text: $searchTerm)
//                    .padding()
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                    .keyboardType(.numberPad)
//
//                // List to display Ayahs and play audio
//                ScrollViewReader { proxy in
//                    List(surahDetail.ayahs) { ayah in
//                        VStack(alignment: .leading) {
//                            HStack {
//                                Text("\(ayah.numberInSurah).")
//                                Spacer()
//                                Text(ayah.text)
//                                    .font(.title3)
//                                    .foregroundColor(.primary)
//                            }
//
//                            HStack {
//                                Button(action: {
//                                    surahStore.fetchAyahAudioUrl(surahNumber: surahDetail.number, ayahNumber: ayah.numberInSurah) { result in
//                                             DispatchQueue.main.async {
//                                                 switch result {
//                                                 case .success(let audioUrl):
//                                                // Check if this is the first Ayah in the Surah, but not Surah 1 or 9
//                                                if ayah.numberInSurah == 1 && surahDetail.number != 1 && surahDetail.number != 9 {
//                                                    if let firstAyahURL = URL(string: firstAyahAudioURL),
//                                                       let ayahURL = URL(string: audioUrl) {
//                                                        audioManager.loadAudio(urls: [firstAyahURL, ayahURL])
//                                                    }
//                                                }
//                                                else{
//                                                    if let url = URL(string: audioUrl) {
//                                                        audioManager.loadAudio(urls: [url]) // Update the AudioManager with the selected Ayah's audio
//                                                    }
//                                                }
//                                                withAnimation {
//                                                    isAudioPlayerVisible.toggle() // Show the audio player
//                                                }
//                                            case .failure(let error):
//                                                print("Failed to fetch audio URL:", error.localizedDescription)
//                                            }
//                                        }
//                                    }
//                                }) {
//                                    Image(systemName: "play.circle.fill")
//                                        .font(.title2)
//                                        .foregroundColor(.blue)
//                                }
//
//
//                                .padding(.leading, 10)
//
//                                // Other buttons (Bookmark, Memorize)
//                                Button(action: {
//                                    // Bookmark logic
//                                }) {
//                                    Image(systemName: "bookmark")
//                                        .font(.title2)
//                                        .foregroundColor(.orange)
//                                }
//
//                                Button(action: {
//                                    // Memorize logic
//                                }) {
//                                    Image(systemName: "checkmark.seal")
//                                        .font(.title2)
//                                        .foregroundColor(.green)
//                                }
//                            }
//                        }
//                        .padding()
//                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
//                        .padding(.horizontal)
//                        .id(ayah.numberInSurah) // Unique ID for scrolling
//                    }
//                    .onChange(of: searchTerm) { newValue in
//                        if let targetNumber = Int(newValue), surahDetail.ayahs.contains(where: { $0.numberInSurah == targetNumber }) {
//                            withAnimation {
//                                proxy.scrollTo(targetNumber, anchor: .center)
//                            }
//                        }
//                    }
//                }
//            } else {
//                ProgressView("Loading Surah Details...")
//            }
//        }
//        .onAppear {
//            surahStore.fetchSurahDetail(surahNumber: surahNumber) { result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let detail):
//                        self.surahDetail = detail // Set the SurahDetail state with the fetched data
//                    case .failure(let error):
//                        print("Failed to fetch Surah detail:", error.localizedDescription)
//                    }
//                }
//            }
//        }
//        .navigationBarTitle(surahDetail?.englishName ?? "Loading...", displayMode: .inline)
//
//        // Audio Player
//        if isAudioPlayerVisible {
//            GeometryReader { geometry in
//                VStack {
//                    Spacer()
//                    AudioPlayerView(audioManager: audioManager)
//                        .frame(width: geometry.size.width, height: 200)
//                        .background(Color.white)
//                        .cornerRadius(20)
//                        .shadow(radius: 5)
//                        .transition(.move(edge: .bottom)) // Slide in/out animation
//                }
//            }
//            .edgesIgnoringSafeArea(.bottom)
//            .background(
//                Color.black.opacity(0.5)
//                    .edgesIgnoringSafeArea(.all)
//                    .onTapGesture {
//                        withAnimation {
//                            isAudioPlayerVisible.toggle() // Hide audio player
//                        }
//                    }
//            )
//        }
//    }

//    // Function to fetch the audio URL for an Ayah
//    func fetchAyahAudioUrl(surahNumber: Int, ayahNumber: Int, completion: @escaping (Result<String, Error>) -> Void) {
//        let urlString = "https://api.alquran.cloud/v1/ayah/\(surahNumber):\(ayahNumber)/audio"
//        guard let url = URL(string: urlString) else {
//            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data else {
//                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
//                return
//            }
//
//            do {
//                let decoder = JSONDecoder()
//                let audioResponse = try decoder.decode(AyahAudioResponse.self, from: data)
//                completion(.success(audioResponse.data.audio)) // Return the audio URL
//            } catch {
//                completion(.failure(error))
//            }
//        }
//
//        task.resume()
//    }
//}


//struct SurahView: View {
////    var surah: Surah
//    @ObservedObject var surahStore = SurahStore()
//
//    @State private var searchTerm: String = ""
//    @State private var isAudioPlayerVisible = false // Controls the visibility of the audio player
//    @StateObject private var audioManager = AudioManager()
//    @State private var surahDetail: SurahDetail?
//    let surahNumber: Int
//    let first_ayah_audio_url = "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3"
//
//    var body: some View {
//        ZStack {
//            // Main Content
//            VStack {
//                // Surah Title and Search Field
//                Text("Surah: \(surahDetail.englishName) (\(surahDetail.englishNameTranslation))")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.primary)
//                    .padding()
//                    .multilineTextAlignment(.center)
//
//                TextField("Search Ayah...(1-\(surahDetail.numberOfAyahs))", text: $searchTerm)
//                    .padding()
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                    .keyboardType(.numberPad)
//
////                if ayahStore.isLoading {
////                    ProgressView("Loading Ayahs...")
////                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
////                        .padding()
////                } else {
//                    ScrollViewReader { proxy in
//                        List(surahDetail.ayahs) { ayah in
//                            VStack{
//                                VStack(alignment: .leading) {
//                                    NavigationLink(destination: AyahDetailView(ayah: ayah, surahDetail: surahDetail)) {
//                                        VStack(alignment: .leading) {
//                                            HStack {
//                                                Text("\(ayah.numberInSurah).")
//                                                Spacer()
//                                                Text(ayah.text)
//                                                    .font(.title3)
//                                                    .foregroundColor(.primary)
//                                            }
//                                        }
//                                    }
//                                    .buttonStyle(PlainButtonStyle())
//
//                                    // Action buttons (Play, Bookmark, Memorized)
//                                    HStack {
//                                        Button(action: {
//                                            // Check if this is the first Ayah in the Surah, but not Surah 1 or 9
//                                            if ayah.numberInSurah == 1 && surahDetail.number != 1 && surahDetail.number != 9 {
//                                                if let firstAyahURL = URL(string: first_ayah_audio_url),
//                                                   let ayahAudioURL = ayah.audio, let ayahURL = URL(string: ayahAudioURL) {
//                                                    audioManager.loadAudio(urls: [firstAyahURL, ayahURL])
//                                                }
//                                            }
//                                            else{
//                                                if let ayahAudioURL = ayah.audio, let url = URL(string: ayahAudioURL) {
//                                                    audioManager.loadAudio(urls: [url]) // Update the AudioManager with the selected Ayah's audio
//                                                }
//                                            }
//                                            withAnimation {
//                                                isAudioPlayerVisible.toggle() // Show the audio player
//                                            }
//                                        }) {
//                                            Image(systemName: "play.circle.fill")
//                                                .font(.title2)
//                                                .foregroundColor(.blue)
//                                        }
//
//                                        .padding(.leading, 10)
//
//                                        Button(action: {
//                                            // Bookmark logic
//                                        }) {
//                                            Image(systemName: "bookmark")
//                                                .font(.title2)
//                                                .foregroundColor(.orange)
//                                        }
//
//                                        Button(action: {
//                                            // Mark Ayah as memorized
//                                        }) {
//                                            Image(systemName: "checkmark.seal")
//                                                .font(.title2)
//                                                .foregroundColor(.green)
//                                        }
//                                    }
//                                }
//                                .padding(.top, 5)
//                                .padding(.bottom, 10)
//                            }
//                            .padding(.vertical, 5)
//                            .background(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.white)
//                                    .shadow(radius: 5)
//                            )
//                            .padding(.horizontal)
//                            .id(ayah.numberInSurah) // Unique ID for scrolling
//                        }
//                        .listStyle(PlainListStyle())
//                        .onChange(of: searchTerm) { newValue in
//                            // Scroll to the searched Ayah
//                            if let targetNumber = Int(newValue),
//                               surahDetail.ayahs.contains(where: { $0.numberInSurah == targetNumber }) {
//                                withAnimation {
//                                    proxy.scrollTo(targetNumber, anchor: .center)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .onAppear {
//                surahStore.fetchSurahDetail(for: surah) // Fetch Ayahs for the selected Surah
//            }
//            .navigationBarTitle(surah.englishName, displayMode: .inline)
//
//            // Audio Player
//            if isAudioPlayerVisible {
//                GeometryReader { geometry in
//                    VStack {
//                        Spacer()
//                        AudioPlayerView(audioManager: audioManager)
//                            .frame(width: geometry.size.width, height: 200)
//                            .background(Color.white)
//                            .cornerRadius(20)
//                            .shadow(radius: 5)
//                            .transition(.move(edge: .bottom)) // Slide in/out animation
//                    }
//                }
//                .edgesIgnoringSafeArea(.bottom)
//                .background(
//                    Color.black.opacity(0.5)
//                        .edgesIgnoringSafeArea(.all)
//                        .onTapGesture {
//                            withAnimation {
//                                isAudioPlayerVisible.toggle() // Hide audio player
//                            }
//                        }
//                )
//            }
//        }
//    }
//}


//struct SurahView: View {
//    var surah: Surah
//    @ObservedObject var ayahStore: AyahStore
//
//    //    @AppStorage("memorizedAyahs") var memorizedAyahs: [Int] = [] // Store Ayah numbers
//    @State private var searchTerm: String = ""
//
//    //    var filteredAyahs: [Ayah] {
//    //        if searchTerm.isEmpty {
//    //            return ayahStore.ayahs
//    //        } else {
//    //            if let searchNumber = Int(searchTerm) {
//    //                return ayahStore.ayahs.filter { $0.numberInSurah == searchNumber }
//    //            } else {
//    //                return []
//    //            }
//    //        }
//    //    }
//    //
//    var body: some View {
//        VStack {
//            // Surah Title and Search Field
//            Text("Surah: \(surah.englishName) (\(surah.englishNameTranslation))")
//                .font(.title2)
//                .fontWeight(.bold)
//                .foregroundColor(.primary)
//                .padding()
//                .multilineTextAlignment(.center)
//
//            TextField("Search Ayah...", text: $searchTerm)
//                .padding()
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding(.horizontal)
//
//            if ayahStore.isLoading {
//                ProgressView("Loading Ayahs...")
//                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                    .padding()
//            } else {
//                ScrollViewReader { proxy in
//                    List(ayahStore.ayahs) { ayah in
//                        VStack(alignment: .leading) {
//                            NavigationLink(destination: AyahDetailView(ayah: ayah, surah: surah)) {
//                                VStack(alignment: .leading) {
//                                    HStack{
//                                        Text("\(ayah.numberInSurah).")
//                                        Spacer()
//                                        Text(ayah.text)
//                                            .font(.title3)
//                                            .foregroundColor(.primary)
//                                    }
//                                }
//                            }
//                            .buttonStyle(PlainButtonStyle())
//
//                            // Action buttons (Play, Bookmark, Memorized)
//                            HStack {
//                                // Play button
//                                Button(action: {
//                                    // Add play Ayah audio action
//                                }) {
//                                    Image(systemName: "play.circle.fill")
//                                        .font(.title2)
//                                        .foregroundColor(.blue)
//                                }
//                                .padding(.leading, 10)
//
//                                // Bookmark button
//                                Button(action: {
//                                    // Implement bookmarking logic
//                                }) {
//                                    Image(systemName: "bookmark")
//                                        .font(.title2)
//                                        .foregroundColor(.orange)
//                                }
//                                Button(action: {
//                                    // Implement bookmarking logic
//                                }) {
//                                    Image(systemName: "checkmark.seal")
//                                        .font(.title2)
//
//                                }
//                            }
//                            .padding(.top, 5)
//                            .padding(.bottom, 10)
//                        }
//                        .padding(.vertical, 5)
//                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
//                        .padding(.horizontal)
//                        .id(ayah.numberInSurah)
//                    }
//                    .listStyle(PlainListStyle())
//                    .onChange(of: searchTerm) { newValue in
//                        // Scroll to the searched Surah number
//                        if let targetNumber = Int(newValue), ayahStore.ayahs.contains(where: { $0.number == targetNumber }) {
//                            withAnimation {
//                                proxy.scrollTo(targetNumber, anchor: .center)
//                            }
//                        }
//                    }
//                    .navigationBarTitle(surah.name, displayMode: .inline)
//                    .onAppear {
//                        ayahStore.fetchAyahs(for: surah)
//                        //            ayahStore.fetchAyahs(for: surah)
//                    }
//                }
//            }
//        }
//    }
//}
    /// Toggles the memorized state of the Ayah
    //    private func toggleMemorized(ayahNumber: Int) {
    //        if memorizedAyahs.contains(ayahNumber) {
    //            memorizedAyahs.removeAll { $0 == ayahNumber }
    //        } else {
    //            memorizedAyahs.append(ayahNumber)
    //        }
    //    }
    //}
    
    
    
    
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
    static var previews: some View {
        SurahView(surahNumber: 1)
            .environmentObject(bookmarkStore)
            .environmentObject(store)
        
    }
}
    
    //    // Toggle bookmark state for a specific Ayah
    //    private func toggleBookmark(for ayah: Ayah) {
    //        if bookmarkedAyahs.contains(ayah.number) {
    //            bookmarkedAyahs.remove(ayah.number)
    //        } else {
    //            bookmarkedAyahs.insert(ayah.number)
    //        }
    //    }
    //}
   
    
    //                             Memorized button (Checkmark)
    //                                                        Button(action: {
    //                                                            toggleMemorized(ayahNumber: ayah.number)
    //                                                        }) {
    //                                                            Image(systemName: memorizedAyahs.contains(ayah.number) ? "checkmark.seal.fill" : "checkmark.seal")
    //                                                                .font(.title2)
    //                                                                .foregroundColor(memorizedAyahs.contains(ayah.number) ? .green : .gray)
    //                                                        }
    //                            .padding(.trailing, 10)
