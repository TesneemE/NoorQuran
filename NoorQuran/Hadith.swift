//
//  Hadith.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/25/24.
//

import Foundation


struct HadithsResponse: Codable {
    let status: Int
    let message: String
    let hadiths: HadithData
}

struct HadithData: Codable {
    let current_page: Int
    let data: [Hadith]
}

struct Hadith: Codable {
    var id: String { hadithNumber }
    let hadithNumber: String
    let englishNarrator: String
    let hadithEnglish: String
//    let hadithUrdu: String
    let hadithArabic: String
    let headingArabic: String?
}

