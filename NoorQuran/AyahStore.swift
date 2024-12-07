//
//  AyahStore.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/25/24.
//
import Foundation
import Combine


//class AyahStore: ObservableObject {
//    @Published var ayahs: [Ayah] = []  // Published array of Ayahs
//    @Published var isLoading: Bool = false  // To manage loading state
//    @Published var errorMessage: String? = nil  // To handle error state
//
//    private let queue = DispatchQueue(label: "com.yourapp.ayahQueue")  // Serial queue to ensure thread-safe mutation
//
//    // Fetch Ayahs for a specific Surah
//    func fetchAyahs(for surah: Surah) async {
//        self.isLoading = true
//        self.errorMessage = nil  // Reset error message before starting the fetch
//        var fetchedAyahs: [Ayah] = []
//
//        // Use async/await to fetch Ayahs concurrently
//        for ayahNum in 1...surah.numberOfAyahs {
//            let urlString = "https://api.alquran.cloud/v1/ayah/\(surah.number):\(ayahNum)"
//            guard let url = URL(string: urlString) else {
//                self.errorMessage = "Invalid URL for Ayah \(ayahNum)"
//                print("Invalid URL for Ayah \(ayahNum)")
//                continue
//            }
//
//            do {
//                // Fetch the data asynchronously
//                let (data, _) = try await URLSession.shared.data(from: url)
//                let response = try JSONDecoder().decode(AyahResponse.self, from: data)
//
//                // Ensure mutation happens safely on the main thread using a serial queue
//                queue.sync {
//                    fetchedAyahs.append(response.data)
//                }
//            } catch {
//                // Handle error during network request or decoding
//                self.errorMessage = "Error fetching Ayah \(ayahNum): \(error.localizedDescription)"
//                print("Error fetching Ayah \(ayahNum): \(error)")
//            }
//        }
//
//        // Update the ayahs array and stop loading once all ayahs are fetched
//        DispatchQueue.main.async {
//            self.ayahs = fetchedAyahs.sorted(by: { $0.number < $1.number })
//            self.isLoading = false
//        }
//    }

//
//HEREEEEEEEE
//
//class AyahStore: ObservableObject { //this seems to be working but if anything switch to /surahNUM ayah struct
//    @Published var ayahs: [Ayah] = []  // Published array of Ayahs
//    @Published var isLoading: Bool = false  // To manage loading state
//    @Published var failedAyahs: [Int] = [] // To log failed ayahs
//    let maxRetries = 3 // Maximum number of retries for fetching an ayah
//    let batchSize = 10 // Number of ayahs to fetch concurrently (for large surahs)
//    
//    func fetchAyahs(for surah: Surah) {
//        isLoading = true
//        var fetchedAyahs: [Ayah] = []
//        let dispatchGroup = DispatchGroup()
//        
//        let totalAyahs = surah.numberOfAyahs
//        var ayahNumbers = Array(1...totalAyahs)
//        
//        // Split the ayah numbers into batches
//        while !ayahNumbers.isEmpty {
//            let batch = ayahNumbers.prefix(batchSize)
//            ayahNumbers.removeFirst(batch.count)
//            
//            for ayahNum in batch {
//                dispatchGroup.enter()
//                fetchAyah(surah: surah.number, ayahNum: ayahNum, retries: maxRetries) { ayah in
//                    if let ayah = ayah {
//                        fetchedAyahs.append(ayah)
//                    } else {
//                        self.failedAyahs.append(ayahNum) // Log failed ayah
//                        print("Failed to fetch Ayah \(ayahNum) after \(self.maxRetries) retries.")
//                    }
//                    dispatchGroup.leave()
//                }
//            }
//            
//            // Wait for this batch to finish before continuing with the next batch
//            dispatchGroup.wait()
//        }
//        
//        dispatchGroup.notify(queue: .main) {
//            self.ayahs = fetchedAyahs.sorted(by: { $0.number < $1.number })
//            self.isLoading = false
//            
//            // Log missing ayahs after all fetch attempts
//            if !self.failedAyahs.isEmpty {
//                print("Failed to fetch the following ayahs: \(self.failedAyahs)")
//            }
//        }
//    }
//    
//    func fetchAyah(surah: Int, ayahNum: Int, retries: Int, completion: @escaping (Ayah?) -> Void) {
//        let urlString = "https://api.alquran.cloud/v1/ayah/\(surah):\(ayahNum)/ar.alafasy"
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL for Ayah \(ayahNum)")
//            completion(nil)
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("Error fetching Ayah \(ayahNum): \(error)")
//                if retries > 0 {
//                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) { // 1 second delay between retries
//                        self.fetchAyah(surah: surah, ayahNum: ayahNum, retries: retries - 1, completion: completion)
//                    }
//                } else {
//                    completion(nil)
//                }
//                return
//            }
//            
//            guard let data = data else {
//                print("No data for Ayah \(ayahNum)")
//                completion(nil)
//                return
//            }
//            
//            do {
//                let response = try JSONDecoder().decode(AyahResponse.self, from: data)
//                completion(response.data)
//            } catch {
//                print("Error decoding Ayah \(ayahNum): \(error)")
//                if retries > 0 {
//                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) { // 1 second delay between retries
//                        self.fetchAyah(surah: surah, ayahNum: ayahNum, retries: retries - 1, completion: completion)
//                    }
//                } else {
//                    completion(nil)
//                }
//            }
//        }.resume()
//    }
//}


////HERE
////class AyahStore: ObservableObject {
////    @Published var ayahs: [Ayah] = []  // Published array of Ayahs
////    @Published var isLoading: Bool = false  // To manage loading state
////    func fetchAyahs(for surah: Surah) {
////        isLoading = true
////        var fetchedAyahs: [Ayah] = []  // Temporary array for storing fetched Ayahs
////        let dispatchGroup = DispatchGroup()
////        let accessQueue = DispatchQueue(label: "com.ayahStore.fetchedAyahs")
////
////        for ayahNum in 1...surah.numberOfAyahs {
////            dispatchGroup.enter()
////            let urlString = "https://api.alquran.cloud/v1/ayah/\(surah.number):\(ayahNum)/ar.alafasy"
////            guard let url = URL(string: urlString) else {
////                print("Invalid URL for Ayah \(ayahNum)")
////                dispatchGroup.leave()
////                continue
////            }
////
////            URLSession.shared.dataTask(with: url) { data, response, error in
////                defer { dispatchGroup.leave() }
////
////                if let error = error {
////                    print("Error fetching Ayah \(ayahNum): \(error.localizedDescription)")
////                    return
////                }
////                guard let data = data else {
////                    print("No data received for Ayah \(ayahNum)")
////                    return
////                }
////
////                do {
////                    let response = try JSONDecoder().decode(AyahResponse.self, from: data)
////                    accessQueue.async {  // Thread-safe access
////                        fetchedAyahs.append(response.data)
////                    }
////                } catch {
////                    print("Error decoding Ayah \(ayahNum): \(error)")
////                }
////            }.resume()
////        }
////
////        dispatchGroup.notify(queue: .main) {
////            self.ayahs = fetchedAyahs.sorted(by: { $0.number < $1.number })  // Update main property
////            self.isLoading = false
////            print("Completed fetching \(self.ayahs.count) ayahs for Surah \(surah.number).")
////        }
////    }
//
////    func fetchAyahs(for surah: Surah) {
////        isLoading = true
////        var fetchedAyahs: [Ayah] = []
////        let dispatchGroup = DispatchGroup()
////
////        for ayahNum in 1...surah.numberOfAyahs {
////            dispatchGroup.enter()
////            let urlString = "https://api.alquran.cloud/v1/ayah/\(surah.number):\(ayahNum)/ar.alafasy"
////            guard let url = URL(string: urlString) else {
////                print("Invalid URL for Ayah \(ayahNum)")
////                dispatchGroup.leave()
////                continue
////            }
////
////            URLSession.shared.dataTask(with: url) { data, response, error in
////                defer { dispatchGroup.leave() }
////                if let error = error {
////                    print("Error fetching Ayah \(ayahNum): \(error)")
////                    return
////                }
////                guard let data = data else {
////                    print("No data for Ayah \(ayahNum)")
////                    return
////                }
////                do {
////                    let response = try JSONDecoder().decode(AyahResponse.self, from: data)
////                    fetchedAyahs.append(response.data)
////                } catch let DecodingError.keyNotFound(key, context) {
////                    print("Key '\(key.stringValue)' not found for Ayah \(ayahNum): \(context.debugDescription)")
////                    print("Error decoding Ayah \(ayahNum)")
////                    print("Error decoding Ayah \(ayahNum) from URL: \(urlString).)")
////                    print("\n\n")
////                } catch {
////                    print("Error decoding Ayah \(ayahNum): \(error)")
////                    print("Error decoding Ayah \(ayahNum) from URL: \(urlString). Error: \(error)")
////                    print("\n\n")
////                }
////            }.resume()
////        }
////
////        dispatchGroup.notify(queue: .main) {
////            self.ayahs = fetchedAyahs.sorted(by: { $0.number < $1.number })
////            self.isLoading = false
////        }
////    }
//
////    // Fetch Ayahs for a given Surah
////    func fetchAyahs(for surah: Surah) {
////        isLoading = true
////        var fetchedAyahs: [Ayah] = []
////        let dispatchGroup = DispatchGroup()
////
////        // Loop through all verses of the surah
////        for ayahNum in 1...surah.numberOfAyahs {
////            dispatchGroup.enter()
////            let urlString = "https://api.alquran.cloud/v1/ayah/\(surah.number):\(ayahNum)/ar.alafasy"
////            guard let url = URL(string: urlString) else {
////                print("Invalid URL for Ayah \(ayahNum)")
////                dispatchGroup.leave()
////                continue
////            }
////
////            // Fetch the Ayah details (text, etc.)
////            URLSession.shared.dataTask(with: url) { data, response, error in
////                defer { dispatchGroup.leave() }
////                if let error = error {
////                    print("Error fetching Ayah \(ayahNum): \(error)")
////                    return
////                }
////                guard let data = data else {
////                    print("No data for Ayah \(ayahNum)")
////                    return
////                }
////                do {
////                    let decoder = JSONDecoder()
////                    let response = try decoder.decode(AyahResponse.self, from: data)
////                    fetchedAyahs.append(response.data)
////                } catch {
////                    print("Error decoding Ayah \(ayahNum): \(error)")
////                    print("Error decoding Ayah \(ayahNum) from URL: \(urlString). Error: \(error)")
////                    print("\n\n")
////
////                }
////            }.resume()
////        }
////
////        // After all Ayahs are fetched
////        dispatchGroup.notify(queue: .main) {
////            self.ayahs = fetchedAyahs.sorted(by: { $0.number < $1.number })
////            self.isLoading = false
////        }
////    }
//
//    // Fetch Audio URL for a specific Ayah
////    func fetchAudioURL(for ayah: Ayah) {
////        let url = URL(string: "https://api.alquran.cloud/v1/ayah/\(ayah.surah.number):\(ayah.numberInSurah)/ar.alafasy")!
////
////        let task = URLSession.shared.dataTask(with: url) { data, response, error in
////            if let data = data {
////                do {
////                    // Decode the JSON response to get the audio URL
////                    let decoder = JSONDecoder()
////                    let result = try decoder.decode(AyahAudioResponse.self, from: data)
////
////                    // Update the audio URL for the specific Ayah in the ayahs array
////                    if let index = self.ayahs.firstIndex(where: { $0.id == ayah.id }) {
////                        DispatchQueue.main.async {
////                            self.ayahs[index].audio = result.data.audio
////                        }
////                    }
////                } catch {
////                    print("Error decoding audio URL: \(error.localizedDescription)")
////                }
////            }
////        }
////
////        task.resume()
////    }
//
////func fetchEnglishTranslation(for ayah: Ayah) {
////    let url = URL(string: "https://api.alquran.cloud/v1/ayah/\(ayah.surah.number):\(ayah.numberInSurah)/en.pickthall")!
////
////    let task = URLSession.shared.dataTask(with: url) { data, response, error in
////        if let data = data {
////            do {
////                // Decode the JSON response to get the audio URL
////                let decoder = JSONDecoder()
////                let result = try decoder.decode(AyahAudioResponse.self, from: data)
////
////                // Update the audio URL for the specific Ayah in the ayahs array
////                if let index = self.ayahs.firstIndex(where: { $0.id == ayah.id }) {
////                    DispatchQueue.main.async {
////                        self.ayahs[index].audio = result.data.audio
////                    }
////                }
////            } catch {
////                print("Error decoding audio URL: \(error.localizedDescription)")
////            }
////        }
////    }
////
////    task.resume()
//}

//class AyahStore: ObservableObject {
//    @Published var ayahs: [Ayah] = [] // Surahs loaded from the API
//
//    init() {
//        loadAyahs()
//    }
//
//    func loadAyahs() {
//        fetchAyahs { [weak self] fetchedAyahs in
//            DispatchQueue.main.async {
//                self?.ayahs = fetchedAyahs ?? []
//            }
//        }
//    }
//}
//func fetchAyahs(completion: @escaping ([Ayah]?) -> Void) {
//    let urlString = "https://api.alquran.cloud/v1/surah/\(surahNum)"
//
//    guard let url = URL(string: urlString) else {
//        print("Invalid URL")
//        completion(nil)
//        return
//    }
//
//    URLSession.shared.dataTask(with: url) { data, response, error in
//        if let error = error {
//            print("Error fetching data: \(error)")
//            completion(nil)
//            return
//        }
//
//        guard let data = data else {
//            print("No data received")
//            completion(nil)
//            return
//        }
//
//        do {
//            let decoder = JSONDecoder()
//            let response = try decoder.decode(SurahResponse.self, from: data)
//            completion(response.data.ayahs) // Pass the array of Surahs to the completion handler
//        } catch {
//            print("Error decoding JSON: \(error)")
//            completion(nil)
//        }
//    }.resume()
//}
