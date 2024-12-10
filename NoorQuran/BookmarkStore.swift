//
//  Bookmark.swift
//  NoorQuran
//
//  Created by Tes Essa on 12/1/24.
//

//

import Foundation
import Combine
struct BookmarkedAyah: Identifiable {
    let surah: Int
    let surahName: String
    let ayah: Int
    let text: String
//    var dateMemorized: Date
    
    var id: String {
        "\(surah):\(ayah)"
    }
}

class BookmarkAyahStore: ObservableObject {
    @Published var bookmarkedAyahs: [BookmarkedAyah] = []
    @Published var loadingError = false
    private let dataURL: URL
    init() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.dataURL = documentsURL.appendingPathComponent("bookmark_ayah_history.plist")
        load()
    }
    func toggleBookmark(for ayah: BookmarkedAyah) {
        if let index = bookmarkedAyahs.firstIndex(where: { $0.surah == ayah.surah && $0.ayah == ayah.ayah }) {
            bookmarkedAyahs.remove(at: index)
        } else {
            bookmarkedAyahs.append(ayah)
        }
        save()
    }
    
    func isBookmarked(surah: Int, ayah: Int) -> Bool {
        return bookmarkedAyahs.contains { $0.surah == surah && $0.ayah == ayah }
    }
    
    func cleanInvalidEntries() {
        bookmarkedAyahs.removeAll { $0.surah <= 0 || $0.ayah <= 0 || $0.surahName.isEmpty }
    }
    
    func save() {
        let plistData: [[String: Any]] = bookmarkedAyahs.map { [
            "surah": $0.surah,
            "surahName": $0.surahName,
            "ayah": $0.ayah,
            "text": $0.text
        ]}
        
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: plistData, format: .binary, options: .zero)
            try data.write(to: dataURL, options: .atomic)
//            print("Saved data: \(plistData)")
        } catch {
            print("Failed to save data:", error.localizedDescription)
        }
    }

    func load() {
        do {
            let data = try Data(contentsOf: dataURL)
            let convertedPlistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]] ?? []
            
            bookmarkedAyahs = convertedPlistData.compactMap { data in
                guard
                    let surah = data["surah"] as? Int, surah > 0,
                    let ayah = data["ayah"] as? Int, ayah > 0,
                    let surahName = data["surahName"] as? String, !surahName.isEmpty,
                    let text = data["text"] as? String, !text.isEmpty
                else { return nil }
                
                return BookmarkedAyah(surah: surah, surahName: surahName, ayah: ayah, text: text)
            }
        } catch {
            print("Failed to load data:", error.localizedDescription)
        }
    }


}
struct BookmarkedHadith: Identifiable {
    let hadithNum: String
    let hadithText: String
    let hadithNarrator: String
//    var dateMemorized: Date
    
    var id: String {
        "\(hadithNum)"
    }
}

class BookmarkHadithStore: ObservableObject {
    @Published var bookmarkedHadiths: [BookmarkedHadith] = []
    @Published var loadingError = false
    private let dataURL: URL
    init() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.dataURL = documentsURL.appendingPathComponent("bookmark_hadith_history.plist")
        load()
    }
    func toggleBookmark(for hadith: BookmarkedHadith) {
        if let index = bookmarkedHadiths.firstIndex(where: { $0.hadithNum == hadith.hadithNum}) {
            bookmarkedHadiths.remove(at: index)
        } else {
            bookmarkedHadiths.append(hadith)
        }
        save()
    }

    func isBookmarked(hadithNum: String) -> Bool {
        return bookmarkedHadiths.contains { $0.hadithNum == hadithNum }
    }

    func cleanInvalidEntries() {
        bookmarkedHadiths.removeAll { $0.hadithNum == "0" || $0.hadithText.isEmpty || $0.hadithNarrator.isEmpty }
    }

    func save() {
        let plistData: [[String: Any]] = bookmarkedHadiths.map { [
            "hadithNum": $0.hadithNum,
            "hadithText": $0.hadithText,
            "hadithNarrator": $0.hadithNarrator
        ]}
        
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: plistData, format: .binary, options: .zero)
            try data.write(to: dataURL, options: .atomic)
//            print("Saved data: \(plistData)")
        } catch {
            print("Failed to save data:", error.localizedDescription)
        }
    }

    func load() {
        do {
            let data = try Data(contentsOf: dataURL)
            let convertedPlistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]] ?? []
            
            bookmarkedHadiths = convertedPlistData.compactMap { data in
                guard
                    let hadithNum = data["hadithNum"] as? String, !hadithNum.isEmpty,
                    let hadithText = data["hadithText"] as? String, !hadithText.isEmpty,
                    let hadithNarrator = data["hadithNarrator"] as? String, !hadithNarrator.isEmpty
                else { return nil }
                
                return BookmarkedHadith(hadithNum: hadithNum, hadithText: hadithText, hadithNarrator: hadithNarrator)
            }
        } catch {
            print("Failed to load data:", error.localizedDescription)
        }
    }

}
