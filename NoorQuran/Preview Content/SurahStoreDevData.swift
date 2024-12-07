//
//  SurahStoreDevData.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/17/24.
//
//import Foundation
//struct Surah: Codable, Hashable {
//  let surahID: Int
//  let title: String
//  let ayaCount: Int
//  let surahURL: String
//}
//
//struct SurahIDs: Codable {
//    let total: Int
//    let surahIDs: [Int]
//}
import Foundation

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

//extension SurahStore {
//  func createDevData() {
//    surahs = [
//      Surah(
//        surahID: 1,
//        title: "Al-Fatiha",
//        ayahCount: 7,
//        ayahMem: 7,
//        surahURL: "https://www.metmuseum.org/art/collection/search/452174"),
//      Surah(
//        surahID: 2,
//        title: "Al-Baqara",
//        ayahCount: 286,
//        ayahMem: 2,
//        surahURL: "https://www.metmuseum.org/art/collection/search/452174"),
//      Surah(
//        surahID: 3,
//        title: "Al-E-Imran",
//        ayahCount: 200,
//        ayahMem: 0,
//        surahURL: "https://www.metmuseum.org/art/collection/search/452174")
//    ]
//  }
//}
