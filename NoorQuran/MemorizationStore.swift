//
//  MemorizationStore.swift
//  NoorQuran
//
//  Created by Tes Essa on 12/5/24.
//

import Foundation
import Combine 
struct MemorizedAyah: Identifiable {
    let surah: Int
    let surahName: String
    let ayah: Int
    var dateMemorized: Date
    
    var id: String {
        "\(surah):\(ayah)"
    }
}

class MemorizationStore: ObservableObject {
    @Published var memorizedAyahs: [MemorizedAyah] = []
    private let dataURL: URL
    
    init() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.dataURL = documentsURL.appendingPathComponent("memorizedAyahs.plist")
        load()
    }
    
    func toggleMemorization(for ayah: MemorizedAyah) {
        if let index = memorizedAyahs.firstIndex(where: { $0.surah == ayah.surah && $0.ayah == ayah.ayah }) {
            memorizedAyahs.remove(at: index)
        } else {
            memorizedAyahs.append(ayah)
        }
        save()
    }
    
    func isMemorized(surah: Int, ayah: Int) -> Bool {
        return memorizedAyahs.contains { $0.surah == surah && $0.ayah == ayah }
    }
    
    func cleanInvalidEntries() {
        memorizedAyahs.removeAll { $0.surah <= 0 || $0.ayah <= 0 || $0.surahName.isEmpty }
    }
    
    func save() {
        let plistData: [[String: Any]] = memorizedAyahs.map { [
            "surah": $0.surah,
            "surahName": $0.surahName,
            "ayah": $0.ayah,
            "dateMemorized": $0.dateMemorized
        ]}
        
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: plistData, format: .binary, options: .zero)
            try data.write(to: dataURL, options: .atomic)
            print("Saved data: \(plistData)")
        } catch {
            print("Failed to save data:", error.localizedDescription)
        }
    }

    func load() {
        do {
            let data = try Data(contentsOf: dataURL)
            let convertedPlistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]] ?? []
            
            memorizedAyahs = convertedPlistData.compactMap { data in
                guard
                    let surah = data["surah"] as? Int, surah > 0,
                    let ayah = data["ayah"] as? Int, ayah > 0,
                    let surahName = data["surahName"] as? String, !surahName.isEmpty,
                    let dateMemorized = data["dateMemorized"] as? Date
                else { return nil }
                
                return MemorizedAyah(surah: surah, surahName: surahName, ayah: ayah, dateMemorized: dateMemorized)
            }
        } catch {
            print("Failed to load data:", error.localizedDescription)
        }
    }
    
    var groupedAyahs: [Date: [MemorizedAyah]] {
        let grouped = Dictionary(grouping: memorizedAyahs) { ayah in
            // Use only the date without time for grouping
            Calendar.current.startOfDay(for: ayah.dateMemorized)
        }
        return grouped
    }
}