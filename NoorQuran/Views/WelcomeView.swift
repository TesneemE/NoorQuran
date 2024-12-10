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
    @StateObject var locationManager = LocationManager()

    @AppStorage("latitude") var userLatitude: Double = -12.28454
    @AppStorage("longitude") var userLongitude: Double = -110.11107

    @EnvironmentObject var memorizationStore: MemorizationStore

    @State private var cancellables: Set<AnyCancellable> = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("Green"), Color("AccentGreen")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Button(action: {
                            locationManager.requestLocation()
                        }) {
                            Image(systemName: "location.square.fill")
                                .foregroundColor(Color("Pink").opacity(0.89))
                                .font(.largeTitle)
                                .padding(15)
                                .background(Capsule().fill(LinearGradient(gradient: Gradient(colors: [Color("AccentPink").opacity(0.8), Color("Pink").opacity(0.6)]), startPoint: .top, endPoint: .bottom)))
                                .shadow(radius: 5)
                        }
                        .padding(.leading)

                        Spacer()

                        Text("NoorQuran")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.all)
                            .background(Capsule().fill(LinearGradient(gradient: Gradient(colors: [Color("AccentPink").opacity(0.8), Color("Pink").opacity(0.6)]), startPoint: .top, endPoint: .bottom)))
                            .shadow(radius: 5)
                    }
                    .padding(.top)
                    .padding(.bottom, 20)

                    if let prayerTimes = prayerTimesStore.currentPrayerTimes {
                        PrayerTimesGrid(prayerTimes: prayerTimes.timings)
                            .padding(.top, 20)
                            .padding(.bottom, 60)
                    } else if let errorMessage = prayerTimesStore.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        PrayerTimesGridPlaceholder()
                    }

                    Spacer()

                    Button("Memorization History") {
                        showMemorization.toggle()
                    }
                    .sheet(isPresented: $showMemorization) {
                        MemorizationView(showMemorization: $showMemorization)
                    }
                    .padding()
                    .frame(width: geometry.size.width * 0.6, height: 100)
                    .foregroundColor(.white)
                    .bold()
                    .multilineTextAlignment(.center)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color("AccentPink").opacity(0.8), Color("Pink").opacity(0.6)]), startPoint: .top, endPoint: .bottom)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    )
                    .padding(.bottom, 200)
                    
                }
                .onAppear {
                    prayerTimesStore.fetchPrayerTimes(latitude: userLatitude, longitude: userLongitude)
                }
                .onChange(of: locationManager.location) { newLocation in
                    if let newLocation = newLocation {
                        fetchPrayerTimesIfNeeded(newLocation)
                    }
                }
                .padding()
            }
        }
    }

    private func fetchPrayerTimesIfNeeded(_ location: CLLocationCoordinate2D) {
        if location.latitude != userLatitude || location.longitude != userLongitude {
            userLatitude = location.latitude
            userLongitude = location.longitude
            prayerTimesStore.fetchPrayerTimes(latitude: userLatitude, longitude: userLongitude, forceUpdate: true)
        } else {
            prayerTimesStore.fetchPrayerTimes(latitude: userLatitude, longitude: userLongitude)
        }
    }
}

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
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    Text(time)
                        .font(.title3)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
                .padding(.all)
                .background(RoundedRectangle(cornerRadius: 15).fill(LinearGradient(gradient: Gradient(colors: [Color("AccentPink").opacity(0.8), Color("Pink").opacity(0.6)]), startPoint: .top, endPoint: .bottom)))
                .shadow(radius: 3)
            }
        }
    }
}

// Placeholder view for loading
struct PrayerTimesGridPlaceholder: View {
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
            ForEach(0..<6) { _ in
                VStack {
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.all)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color("AccentPink").opacity(0.8)))
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
