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
struct AyahsMemorizedWeekly: Identifiable {
    let date: Date
    let count: Int
    var id: Date { date }
}

extension Date {
    var previousSevenDays: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
    
        for dayOffset in 0..<7 {
            if let previousDay = calendar.date(byAdding: .day, value: -dayOffset, to: self) {
                let startOfDay = calendar.startOfDay(for: previousDay)
                dates.append(startOfDay)
            }
        }
        return dates
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
//            print("Saved data: \(plistData)")
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
    
    var groupedAyahs: [Date: [MemorizedAyah]] { //for grouping by date
        let grouped = Dictionary(grouping: memorizedAyahs) { ayah in
            Calendar.current.startOfDay(for: ayah.dateMemorized)
        }
        return grouped
    }
    func weeklyMemorizedAyahs() -> [AyahsMemorizedWeekly] {
        let today = Date()
        let lastSevenDays = today.previousSevenDays //extension for last 7 days
        let grouped = self.groupedAyahs //groups by date

        return lastSevenDays.map { date in  //then maps to diff struct for counting ayahs per day
            let ayahsOnDate = grouped[date] ?? []
            return AyahsMemorizedWeekly(date: date, count: ayahsOnDate.count)
        }
    }
}

