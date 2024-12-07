//
//  Surah.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/17/24.
//

// Surah.swift
import Foundation


struct SurahSummary: Codable, Identifiable {
    let number: Int
    var id: Int { number }
    let name: String
    let englishName: String
    let englishNameTranslation: String
    let numberOfAyahs: Int
    let revelationType: String
}
struct SurahListResponse: Decodable {
    let code: Int
    let status: String
    let data: [SurahSummary] // Array of Surahs
}

struct SurahDetail: Codable {
    let number: Int
    let name: String
    let englishName: String
    let englishNameTranslation: String
    let numberOfAyahs: Int
    let revelationType: String
    let ayahs: [Ayah]
}
struct SurahDetailResponse: Decodable {
    let data: SurahDetail
}

struct Ayah: Codable, Identifiable, Hashable {
    let number: Int
    var id: Int { numberInSurah }
    let text: String
    let numberInSurah: Int
//    let juz: Int
//    let manzil: Int
//    let page: Int
//    let ruku: Int
//    let hizbQuarter: Int
//    let sajda: Bool
}
struct AyahAudio: Codable {
    let number: Int
    let audio: String
    let audioSecondary: [String]
    let text: String
}

struct AyahAudioResponse: Decodable {
    let data: AyahAudio
}

//struct SurahTranslationDetail: Codable {
//    let number: Int
//    let name: String
//    let englishName: String
//    let numberOfAyahs: Int
//    let ayahs: [AyahTranslation]
//}
struct AyahTranslationResponse: Decodable {
    let data: AyahTranslation
}
struct AyahTranslation: Codable{
    let number: Int
    var id: Int { numberInSurah }
    let text: String
    let numberInSurah: Int
}
// Surah model representing a single Surah's details
//struct Surah: Codable, Identifiable {
//    let number: Int
//    let name: String
//    let englishName: String
//    let englishNameTranslation: String
//    let revelationType: String
//    let numberOfAyahs: Int
//    var id: Int { number }
//}
//
//struct Surah: Identifiable, Equatable, Codable {
//    let number: Int
//    var id: Int { number }
//    var name: String
//    var englishName: String
//    var englishNameTranslation: String
//    var revelationType: String
//    var numberOfAyahs: Int
////    let ayahs: [Ayah]
//
//    // Equatable conformance ensures Surah can be compared
//    static func == (lhs: Surah, rhs: Surah) -> Bool {
//        return lhs.id == rhs.id
//    }
//}

////struct SurahResponse: Codable {
////    let code: Int
////    let status: String
////    let data: [Surah] //if use /surah/num in api call no longer a struct plus just need to do from 1 to 114
////}
//struct SurahResponse: Codable {
//    let code: Int
//    let status: String
//    let data: SurahDetail
//}
//
//struct SurahDetail: Codable {
//    let number: Int
//    let name: String
//    let englishName: String
//    let englishNameTranslation: String
//    let numberOfAyahs: Int
//    let revelationType: String
//    let ayahs: [Ayah]
//}
//
//struct Ayah: Codable, Identifiable {
//    let number: Int
//    var id: Int { number } // For Identifiable
//    let text: String
//    let numberInSurah: Int
////    let juz: Int
////    let manzil: Int
////    let page: Int
////    let ruku: Int
////    let hizbQuarter: Int
////    let sajda: Bool
//}
//
////struct SurahData {
////    let id: Int
////    let title: String
////    let translation: String
////    let revelationType: String
////    let totalAyahs: Int
////    var ayahsMemorized: Int = 0 // Customizable and mutable property
////}
