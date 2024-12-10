//
//  PrayerTimesStore.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/29/24.
//

import Foundation
import Combine

class PrayerTimesStore: ObservableObject {
    private let lastGeneratedDateKey = "lastGeneratedDate"
    private let lastGeneratedPrayerTimesKey = "lastGeneratedPrayerTimes"

    @Published var currentPrayerTimes: PrayerTimes? = nil
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()

    // Fetch prayer times based on latitude and longitude, with an option for force update
    func fetchPrayerTimes(latitude: Double, longitude: Double, forceUpdate: Bool = false) {
        let calendar = Calendar.current
//        let now = Date.now

        // if forceUpdate is true always fetch new data from the API- for when loc changes
        if forceUpdate {
            fetchPrayerTimesFromAPI(latitude: latitude, longitude: longitude)
            return
        }

        //if not check if new day to refetch
        if let lastDate = UserDefaults.standard.object(forKey: lastGeneratedDateKey) as? Date,
           calendar.isDateInToday(lastDate),
           let savedData = UserDefaults.standard.data(forKey: lastGeneratedPrayerTimesKey),
           let savedPrayerTimes = try? JSONDecoder().decode(PrayerTimes.self, from: savedData) {
            self.currentPrayerTimes = savedPrayerTimes
            return
        }

    
        fetchPrayerTimesFromAPI(latitude: latitude, longitude: longitude)
    }

    // Function to fetch prayer times from the API and cache them
    private func fetchPrayerTimesFromAPI(latitude: Double, longitude: Double) {
//        let calendar = Calendar.current
        let now = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Date format for endpoint
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") //cause when my sim was in arabic wrong date format
        let formattedDate = dateFormatter.string(from: now)

        let urlString = "https://api.aladhan.com/v1/timings/\(formattedDate)?latitude=\(latitude)&longitude=\(longitude)"
//        print("URL: \(urlString)")
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL: \(urlString)"
            }
            return
        }

        // fetch prayer times
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PrayerTimesResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch prayer times: \(error.localizedDescription)"
                case .finished:
                    break
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }

                self.currentPrayerTimes = response.data
                self.errorMessage = nil

                // Cache the fetched data for later use
                if let encodedPrayerTimes = try? JSONEncoder().encode(response.data) {
                    UserDefaults.standard.set(encodedPrayerTimes, forKey: self.lastGeneratedPrayerTimesKey)
                    UserDefaults.standard.set(now, forKey: self.lastGeneratedDateKey)
                }
            }
            .store(in: &cancellables)
    }
}
