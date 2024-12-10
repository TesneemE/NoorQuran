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
    // just realized this wasn't working cause it had the same key as prayer times finally fixed
    private let lastGeneratedHadithDateKey = "lastGeneratedHadithDate"
    private let lastGeneratedHadithKey = "lastGeneratedHadith"
    let apiKey = "$2y$10$u18XVzEkzHYUGY9nDf6g7K3BeMiVCrWWi6hi2uob47o55pFEz6S"

    @Published var randomNumber: Int = 0
    @Published var currentHadith: Hadith? = nil
    @Published var hadithBookmarks: [Hadith] = []

    // fetched new Hadith every day
    func fetchHadith() {
        let now = Date()
        let calendar = Calendar.current

        // check if todays date same as last date
        if let lastDate = UserDefaults.standard.object(forKey: lastGeneratedHadithDateKey) as? Date,
           calendar.isDateInToday(lastDate),
           let savedData = UserDefaults.standard.data(forKey: lastGeneratedHadithKey),
           let savedHadith = try? JSONDecoder().decode(Hadith.self, from: savedData) {
            self.currentHadith = savedHadith
//            print("Loaded saved Hadith for today.")
            return
        }

        // if diff fetch new based on randomized int
        randomNumber = Int.random(in: 1...7563)
        let urlString = "https://www.hadithapi.com/api/hadiths/?apiKey=\(apiKey)&hadithNumber=\(randomNumber)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        // fetching
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
                            // save new Hadith + current date to UserDefaults
                            if let encodedHadith = try? JSONEncoder().encode(firstHadith) {
                                UserDefaults.standard.set(encodedHadith, forKey: self.lastGeneratedHadithKey)
                                UserDefaults.standard.set(now, forKey: self.lastGeneratedHadithDateKey)
                                UserDefaults.standard.synchronize() // make sure it's saved right away
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
}
