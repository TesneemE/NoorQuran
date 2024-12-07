//
//  SurahStore.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/17/24.
//

//import Foundation
//
//class SurahStore: ObservableObject {
//  @Published var surahs: [Surah] = []
//
//  init() {
//    #if DEBUG
//    createDevData() //create objects array
//    #endif
//  }
//}
import Foundation
import Combine

class SurahStore: ObservableObject {
    @Published var surahs: [SurahSummary] = []
    @Published var errorMessage: String? = nil // To handle errors if needed
    
    
    // Fetch Surahs from the API
    func fetchSurahs() {
        let urlString = "https://api.alquran.cloud/v1/surah"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(SurahListResponse.self, from: data)
                    self.surahs = response.data // Assign the array of Surahs
                } catch {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func fetchSurahDetail(surahNumber: Int, completion: @escaping (Result<SurahDetail, Error>) -> Void) {
        let urlString = "https://api.alquran.cloud/v1/surah/\(surahNumber)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(SurahDetailResponse.self, from: data)
                completion(.success(response.data)) // Extract the `data` field
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    //    func fetchAyahAudio(ayahNumber: Int, completion: @escaping (Result<AyahAudio, Error>) -> Void) {
    //        let urlString = "https://api.alquran.cloud/v1/ayah/\(ayahNumber)/ar.alafasy"
    //        guard let url = URL(string: urlString) else { return }
    //
    //        URLSession.shared.dataTask(with: url) { data, response, error in
    //            if let error = error {
    //                completion(.failure(error))
    //                return
    //            }
    //
    //            guard let data = data else { return }
    //            do {
    //                let response = try JSONDecoder().decode(AyahAudioResponse.self, from: data)
    //                completion(.success(response.data)) // Extract the `data` field
    //            } catch {
    //                completion(.failure(error))
    //            }
    //        }.resume()
    //    }
    func fetchAyahAudioUrl(surahNumber: Int, ayahNumber: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://api.alquran.cloud/v1/ayah/\(surahNumber):\(ayahNumber)/ar.alafasy"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let audioResponse = try decoder.decode(AyahAudioResponse.self, from: data)
                completion(.success(audioResponse.data.audio))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    func fetchAyahTranslation(surahNumber: Int, ayahNumber: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://api.alquran.cloud/v1/ayah/\(surahNumber):\(ayahNumber)/en.pickthall"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let textResponse = try decoder.decode(AyahTranslationResponse.self, from: data)
                completion(.success(textResponse.data.text))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}



//    @Published var surahs: [Surah] = [] // Surahs loaded from the API
//
//    init() {
//        loadSurahs()
//    }
//
//    func loadSurahs() {
//        fetchSurahs { [weak self] fetchedSurahs in
//            DispatchQueue.main.async {
//                self?.surahs = fetchedSurahs ?? []
//            }
//        }
//    }
//}
//func fetchSurahs(completion: @escaping ([Surah]?) -> Void) {
//    let urlString = "https://api.alquran.cloud/v1/surah"
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
//            completion(response.data) // Pass the array of Surahs to the completion handler
//        } catch {
//            print("Error decoding JSON: \(error)")
//            completion(nil)
//        }
//    }.resume()
//}
//struct SurahView: View {
//    let surahNumber: Int
//    @State private var surahDetail: SurahDetail?
//    @State private var errorMessage: String?
//
//    var body: some View {
//        Group {
//            if let surahDetail = surahDetail {
//                List(surahDetail.ayahs, id: \.number) { ayah in
//                    Text("\(ayah.numberInSurah): \(ayah.text)")
//                }
//            } else if let errorMessage = errorMessage {
//                Text("Error: \(errorMessage)")
//            } else {
//                ProgressView("Loading...")
//            }
//        }
//        .onAppear {
//            fetchSurahDetail(surahNumber: surahNumber) { result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let detail):
//                        self.surahDetail = detail
//                    case .failure(let error):
//                        self.errorMessage = error.localizedDescription
//                    }
//                }
//            }
//        }
//    }
//
