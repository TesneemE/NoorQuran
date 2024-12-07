//
//  MemorizationView.swift
//  NoorQuran
//
//  Created by Tes Essa on 12/5/24.
//


//import SwiftUI
//
//struct MemorizationView: View {
//    @EnvironmentObject var memorization: MemorizationStore
//    @Binding var showMemorization: Bool
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            Button(action: { showMemorization.toggle() }) {
//                Image(systemName: "xmark.circle")
//            }
//            .font(.title)
//            .padding()
//
//            VStack {
//                Text("History")
//                    .font(.title)
//                    .padding()
//
//                Form {
//                    ForEach(memorization.memorizedAyahs) { mem in
//                        Section(
//                            header:
//                                Text(mem.dateMemorized.formatted(as: "MMM d"))
//                                .font(.headline)) {
//
//                            HStack {
//                                Text("Surah \(mem.surahName), Ayah \(mem.ayah)") // Use the correct property names here
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct MemorizationView_Previews: PreviewProvider {
//  static var previews: some View {
//    MemorizationView(showMemorization: .constant(true))
//      .environmentObject(MemorizationStore())
//  }
//}
import SwiftUI

struct MemorizationView: View {
    @EnvironmentObject var memorizationStore: MemorizationStore
    @Binding var showMemorization: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: { showMemorization.toggle() }) {
                Image(systemName: "xmark.circle")
                    .font(.title)
                    .padding()
            }

            NavigationView {
                if memorizationStore.groupedAyahs.isEmpty {
                    // Display a message when no data is available
                    Text("No memorized ayahs to display.")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List {
                        ForEach(memorizationStore.groupedAyahs.keys.sorted(by: >), id: \.self) { date in
                            if let ayahs = memorizationStore.groupedAyahs[date], !ayahs.isEmpty {
                                Section(header: Text(date, formatter: DateFormatter.shortDate)) {
                                    ForEach(ayahs) { ayah in
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("Surah \(ayah.surah): \(ayah.surahName)")
                                                .font(.headline)
                                            Text("Ayah \(ayah.ayah)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.vertical, 5)
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("Memorization History")
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


