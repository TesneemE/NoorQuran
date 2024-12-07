//
//  SurahListView.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/24/24.
//

import SwiftUI

struct SurahListView: View {
    @EnvironmentObject var memorizationStore: MemorizationStore
    
    @EnvironmentObject var bookmarkAyahStore: BookmarkAyahStore
    
    @StateObject var store = SurahStore() // ObservableObject for API data
    @State private var searchTerm: String = "" // State variable for search input
    var filteredSurahs: [SurahSummary] {
        if searchTerm.isEmpty {
            return store.surahs
        } else if let searchNumber = Int(searchTerm) {
            return store.surahs.filter { $0.number == searchNumber }
        } else {
            return store.surahs.filter {
                $0.name.contains(searchTerm) ||
                $0.englishName.contains(searchTerm) ||
                $0.englishNameTranslation.contains(searchTerm)
            }
        }
    }
//    struct MemorizedAyah: Identifiable {
//        let surah: Int
//        var surahName: String
//        let ayah: Int
//        var text: String
//        var dateMemorized: Date
//
//        var id: String {
//            "\(surah):\(ayah)"
//        }
//    }
    var body: some View {
           NavigationStack {
               VStack(spacing: 16) {
                   // Search Field
                   TextField("Search Surah by number or name", text: $searchTerm)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .padding(.horizontal)
                   
                   // Scrollable List
                   ScrollViewReader { proxy in
                       List(filteredSurahs) { surah in
                           NavigationLink(destination: SurahView(surahNumber: surah.number)){
                               HStack {
                                   VStack(alignment: .leading, spacing: 4) {
                                       Text("\(surah.number). \(surah.englishName)")
                                           .font(.headline)
                                       Text(surah.name)
                                           .font(.subheadline)
                                           .foregroundColor(.secondary)
                                   }
                                   Spacer()
                                   Text("\(surah.numberOfAyahs) Ayahs")
                                       .font(.caption)
                                       .foregroundColor(.green)
                                       .padding(6)
                                       .background(Capsule().fill(Color.green.opacity(0.2)))
                               }
                               .padding(.vertical, 8)
                           }
                           .id(surah.number)
                       }
                       .listStyle(InsetGroupedListStyle())
                   }
               }
               .navigationTitle("Surahs")
               .background(Color(.systemGroupedBackground))
               .onAppear {
                   if store.surahs.isEmpty {
                       store.fetchSurahs()
                   }
               }
           }
       }
   }

struct SurahListView_Previews: PreviewProvider {
    static var bookmarkStore: BookmarkAyahStore = {
        let store = BookmarkAyahStore()
        store.bookmarkedAyahs = [
            BookmarkedAyah(surah: 1, surahName: "Al-Fatiha", ayah: 1, text: ""),
            BookmarkedAyah(surah: 2, surahName: "Al-Baqara", ayah: 255, text: "")
        ]
        return store
    }()
    static var store: MemorizationStore = {
        let store = MemorizationStore()
        store.memorizedAyahs = [
            MemorizedAyah(surah: 1, surahName: "Al-Fatiha", ayah: 1, dateMemorized: Date()),
            MemorizedAyah(surah: 2, surahName: "Al-Baqara", ayah: 255, dateMemorized: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        ]
        return store
    }()
    static var previews: some View {
        SurahListView()
            .environmentObject(bookmarkStore)
            .environmentObject(store)
            }
        }
