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
    let data: [SurahSummary] // Array of Surahs cause endpoint /surah
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


struct AyahTranslationResponse: Decodable {
    let data: AyahTranslation
}
struct AyahTranslation: Codable{
    let number: Int
    var id: Int { numberInSurah }
    let text: String
    let numberInSurah: Int
}
