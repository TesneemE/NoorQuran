//
//  HadithStore.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/25/24.
//
//
import Foundation
import Combine

class HadithStore: ObservableObject {
    private let lastGeneratedDateKey = "lastGeneratedDate"
    private let lastGeneratedHadithKey = "lastGeneratedHadith"
    private let bookmarksKey = "hadithBookmarks"
    let apiKey = "$2y$10$u18XVzEkzHYUGY9nDf6g7K3BeMiVCrWWi6hi2uob47o55pFEz6S"

    @Published var randomNumber: Int = 0
    @Published var currentHadith: Hadith? = nil
    @Published var hadithBookmarks: [Hadith] = []

    // Fetches a new Hadith if the date has changed
    func fetchHadith(for timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        let now = Date()
        let lastGeneratedDate = UserDefaults.standard.object(forKey: lastGeneratedDateKey) as? Date

        // Check if the hadith has already been fetched for the current day
        if let lastDate = lastGeneratedDate, isSameDate(lastDate, now, in: timeZone) {
            // Load the previously saved Hadith from UserDefaults
            if let savedData = UserDefaults.standard.data(forKey: lastGeneratedHadithKey),
               let savedHadith = try? JSONDecoder().decode(Hadith.self, from: savedData) {
                self.currentHadith = savedHadith
                return
            }
        }

        // Fetch a new Hadith
        randomNumber = Int.random(in: 1...7563)
        let urlString = "https://www.hadithapi.com/api/hadiths/?apiKey=\(apiKey)&hadithNumber=\(randomNumber)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let fetchedResponse = try JSONDecoder().decode(HadithsResponse.self, from: data)
                    if let firstHadith = fetchedResponse.hadiths.data.first {
                        DispatchQueue.main.async {
                            self.currentHadith = firstHadith

                            // Save the fetched Hadith and current date to UserDefaults
                            if let encodedHadith = try? JSONEncoder().encode(firstHadith) {
                                UserDefaults.standard.set(encodedHadith, forKey: self.lastGeneratedHadithKey)
                                UserDefaults.standard.set(now, forKey: self.lastGeneratedDateKey)
                            }
                        }
                    } else {
                        print("No hadith found.")
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }

    // Helper function to get the current date in the specified time zone
    private func getCurrentDate(for timeZone: TimeZone) -> Date {
        let now = Date()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.startOfDay(for: now)
    }

    // Helper function to check if two dates are the same day in the specified time zone
    private func isSameDate(_ date1: Date, _ date2: Date, in timeZone: TimeZone) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.isDate(date1, equalTo: date2, toGranularity: .day)
    }
}

//import Foundation
//import Combine
//class HadithStore: ObservableObject {
//    private let lastFetchedKey = "lastFetchedDate"
//    private let savedHadithKey = "savedHadith"
//
//    @Published var randomNumber: Int = 0
//    @Published var currentHadith: Hadith? = nil
//    @Published var hadithBookmarks: [Hadith] = []
//
//    private let lastGeneratedDateKey = "lastGeneratedDate"
//    private let lastGeneratedHadithKey = "lastGeneratedHadith"
//    private let bookmarksKey = "hadithBookmarks"
//    let apiKey = "$2y$10$u18XVzEkzHYUGY9nDf6g7K3BeMiVCrWWi6hi2uob47o55pFEz6S"
//
//    func fetchHadith() {
//        let calendar = Calendar.current
//        let now = Date.now
//        let lastGeneratedDate = UserDefaults.standard.object(forKey: lastGeneratedDateKey) as? Date
//
//        // Check if last fetched date is today
//        if let lastDate = lastGeneratedDate, calendar.isDateInToday(lastDate) {
//            // Load previously saved Hadith from UserDefaults
//            if let savedData = UserDefaults.standard.data(forKey: lastGeneratedHadithKey),
//               let savedHadith = try? JSONDecoder().decode(Hadith.self, from: savedData) {
//                self.currentHadith = savedHadith
//                return
//            }
//        }
//
//        // Fetch a new Hadith
//        randomNumber = Int.random(in: 1...7563)
//        let urlString = "https://www.hadithapi.com/api/hadiths/?apiKey=\(apiKey)&hadithNumber=\(randomNumber)"
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//
//        // Fetch the Hadith from the API
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            if let error = error {
//                print("Error fetching data: \(error.localizedDescription)")
//                return
//            }
//
//            if let data = data {
//                do {
//                    let fetchedResponse = try JSONDecoder().decode(HadithsResponse.self, from: data)
//                    if let firstHadith = fetchedResponse.hadiths.data.first {
//                        DispatchQueue.main.async {
//                            self.currentHadith = firstHadith // Set the fetched data here
//
//                            // Save the fetched Hadith and the current date to UserDefaults
//                            if let encodedHadith = try? JSONEncoder().encode(firstHadith) {
//                                UserDefaults.standard.set(encodedHadith, forKey: self.lastGeneratedHadithKey)
//                                UserDefaults.standard.set(now, forKey: self.lastGeneratedDateKey)
//                            }
//                        }
//                    } else {
//                        print("No hadith found.")
//                    }
//                } catch {
//                    print("Error decoding data: \(error)")
//                }
//            }
//        }.resume()
//    }

//
//    func addBookmark(hadith: Hadith) {
//        if !hadithBookmarks.contains(where: { $0.id == hadith.id }) {
//            hadithBookmarks.append(hadith)
//            saveBookmarks()
//        }
//    }
//
//    func removeBookmark(hadith: Hadith) {
//        hadithBookmarks.removeAll { $0.id == hadith.id }
//        saveBookmarks()
//    }
//
//    private func saveBookmarks() {
//        if let encoded = try? JSONEncoder().encode(hadithBookmarks) {
//            UserDefaults.standard.set(encoded, forKey: bookmarksKey)
//        }
//    }
//
//    private func loadBookmarks() {
//        if let savedData = UserDefaults.standard.data(forKey: bookmarksKey),
//           let savedBookmarks = try? JSONDecoder().decode([Hadith].self, from: savedData) {
//            self.hadithBookmarks = savedBookmarks
//        }
//    }



