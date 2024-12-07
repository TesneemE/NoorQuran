//
//  WelcomeView.swift
//  NoorQuran
//
//  Created by Tes Essa on 10/17/24.
//

import SwiftUI
import Combine
import CoreLocation

struct WelcomeView: View {
    @StateObject var prayerTimesStore = PrayerTimesStore()
    @State private var showMemorization = false
    @StateObject var locationManager = LocationManager()  // LocationManager instance
    
    @AppStorage("latitude") var userLatitude: Double = -12.28454
    @AppStorage("longitude") var userLongitude: Double = -110.11107
    
    @EnvironmentObject var memorizationStore: MemorizationStore
    
    @State private var cancellables: Set<AnyCancellable> = []
    
    var body: some View {
        VStack {
            HStack {
                Button("Get Location") {
                    // When the button is pressed, request the location and force an update
                    locationManager.requestLocation()
                }
                .padding()
                .background(Capsule().fill(Color.green))
                .foregroundColor(.white)
                .font(.headline)
                
                Spacer()
            }
            .padding(.top)

            if let prayerTimes = prayerTimesStore.currentPrayerTimes {
                // Display prayer times dynamically
                PrayerTimesGrid(prayerTimes: prayerTimes.timings)
            } else if let errorMessage = prayerTimesStore.errorMessage {
                // Display error message
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                // Show placeholders while loading
                PrayerTimesGridPlaceholder()
            }

            Spacer()
            
            Button("Memorization History") {
                showMemorization.toggle()
            }
            .sheet(isPresented: $showMemorization) {
                MemorizationView(showMemorization: $showMemorization)
            }
            .padding(.bottom)
        }
        .onAppear {
        //demo testing not really working cayse of user defaults
//            UserDefaults.standard.removeObject(forKey: "latitude")
//                UserDefaults.standard.removeObject(forKey: "longitude")
//
////                // Optionally set demo values if necessary (or let it fetch based on actual location)
////                UserDefaults.standard.set(40.7128, forKey: "latitude")  // New York latitude for demo
////                UserDefaults.standard.set(-74.0060, forKey: "longitude") // New York longitude for demo
//                let demoLatitude: Double = -12.28454
//
//                let demoLongitude: Double = -110.11107
//                userLatitude = demoLatitude
//                userLongitude = demoLongitude
                // Fetch prayer times for the demo location
                prayerTimesStore.fetchPrayerTimes(latitude: userLatitude, longitude: userLongitude)
        }
        .onChange(of: locationManager.location) { newLocation in
            if let newLocation = newLocation {
                // Fetch prayer times only if the location has changed
                fetchPrayerTimesIfNeeded(newLocation)
            }
        }
        .padding()
    }

    private func fetchPrayerTimesIfNeeded(_ location: CLLocationCoordinate2D) {
        // Compare the current location with the stored location in AppStorage
        if location.latitude != userLatitude || location.longitude != userLongitude {
            // Location has changed, update stored values in AppStorage
            userLatitude = location.latitude
            userLongitude = location.longitude
            // Fetch prayer times for the updated location and force update
            prayerTimesStore.fetchPrayerTimes(latitude: userLatitude, longitude: userLongitude, forceUpdate: true)
        } else {
            // If location hasn't changed, fetch prayer times without forcing an update
            prayerTimesStore.fetchPrayerTimes(latitude: userLatitude, longitude: userLongitude)
        }
    }
}


// Subview for displaying prayer times dynamically
struct PrayerTimesGrid: View {
    let prayerTimes: prayer_timings
    
    var body: some View {
        let times = [
            ("Fajr", prayerTimes.Fajr),
            ("Sunrise", prayerTimes.Sunrise),
            ("Dhuhr", prayerTimes.Dhuhr),
            ("Asr", prayerTimes.Asr),
            ("Maghrib", prayerTimes.Maghrib),
            ("Isha", prayerTimes.Isha)
        ]
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
            ForEach(times, id: \.0) { name, time in
                VStack {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.green)
                    Text(time)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.green.opacity(0.2)))
            }
        }
    }
}

// Placeholder view while loading
struct PrayerTimesGridPlaceholder: View {
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
            ForEach(0..<6) { _ in
                VStack {
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.green.opacity(0.1)))
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var store: MemorizationStore = {
        let store = MemorizationStore()
        store.memorizedAyahs = [
            MemorizedAyah(surah: 1, surahName: "Al-Fatiha", ayah: 1, dateMemorized: Date()),
            MemorizedAyah(surah: 2, surahName: "Al-Baqara", ayah: 255, dateMemorized: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        ]
        return store
    }()

    static var previews: some View {
        WelcomeView()
            .environmentObject(store)
    }
}

