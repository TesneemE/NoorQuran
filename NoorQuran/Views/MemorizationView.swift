//
//  MemorizationView.swift
//  NoorQuran
//
//  Created by Tes Essa on 12/2/24.
//
import SwiftUI

import Charts
import Foundation

struct MemorizationView: View {
    @EnvironmentObject var memorizationStore: MemorizationStore
    @Binding var showMemorization: Bool
    @State private var selectedHistoryView = 1
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("AccentPink").opacity(0.8), Color("Pink").opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer()
                    Button(action: { showMemorization.toggle() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }

                Spacer()
                Picker(selection: $selectedHistoryView, label: Text("Bookmarks")){
                    Text("Memorized Ayahs")
                        .tag(1)
                    Text("Charts")
                        .tag(2)
                }
    
                .pickerStyle(SegmentedPickerStyle())
                .padding()
               .colorMultiply(Color("AccentGreen"))

                if selectedHistoryView == 1{
                    NavigationStack {
                        if memorizationStore.groupedAyahs.isEmpty {
                            Text("No memorized ayahs to display.")
                                .foregroundColor(.black)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [Color("AccentPink").opacity(0.8), Color("Pink").opacity(0.6)]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ))
                                        .padding()
                                )
                        } else {
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("AccentPink").opacity(0.8), Color("Pink").opacity(0.6)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .edgesIgnoringSafeArea(.all)
                                
                                List {
                                    ForEach(memorizationStore.groupedAyahs.keys.sorted(by: >), id: \.self) { date in
                                        if let ayahs = memorizationStore.groupedAyahs[date], !ayahs.isEmpty {
                                            Section(header: Text(date, formatter: DateFormatter.shortDate).foregroundColor(.black)) {
                                                ForEach(ayahs) { ayah in
                                                    VStack(alignment: .leading, spacing: 5) {
                                                        Text("Surah \(ayah.surah): \(ayah.surahName)")
                                                            .font(.headline)
                                                            .foregroundColor(.black)
                                                            .bold()
                                                        HStack {
                                                            Text("Ayah \(ayah.ayah)")
                                                                .font(.subheadline)
                                                                .foregroundColor(.secondary)
                                                            Spacer()
                                                            Button(action: {
                                                                memorizationStore.toggleMemorization(for: ayah)
                                                            }) {
                                                                Image(systemName: "checkmark.seal")
                                                                    .foregroundColor(memorizationStore.isMemorized(surah: ayah.surah, ayah: ayah.ayah) ? Color("Pink") : .gray)
                                                                    .font(.title3)
                                                            }
                                                            .buttonStyle(.plain)
                                                        }
                                                    }
                                                    .padding()
                                                    .contentShape(Rectangle())
                                                    .listRowBackground(Color("AccentGreen"))
                                                }
                                            }
                                        }
                                    }
                                }
                                .navigationTitle("Memorization History")
                                .toolbarBackground(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color("AccentPink").opacity(0.8), Color("Pink").opacity(0.6)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    for: .navigationBar
                                )
                                .toolbarBackground(.visible, for: .navigationBar)
                                .listStyle(PlainListStyle())
                            }
                        } //end to else  here
                    } //end to nav stack here
                }
                else
                {
                    BarChartWeekView()
                        .environmentObject(memorizationStore)
                }
            }
        }
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}


struct MemorizationView_Previews: PreviewProvider {
        static var store: MemorizationStore = {
            let store = MemorizationStore()
            store.memorizedAyahs = [
                MemorizedAyah(surah: 1, surahName: "Al-Fatiha", ayah: 1, dateMemorized: Date()),
                MemorizedAyah(surah: 2, surahName: "Al-Baqara", ayah: 255, dateMemorized: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
            ]
            return store
        }()
    
    static var previews: some View {
        MemorizationView(showMemorization: .constant(true))
            .environmentObject(store)
    }
    
}


