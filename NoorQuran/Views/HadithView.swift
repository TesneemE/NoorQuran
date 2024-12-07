//
//  HadithView.swift
//  NoorQuran
//
//  Created by Tes Essa on 10/17/24.
//

import SwiftUI

struct HadithView: View {
    @StateObject var hadithStore = HadithStore()
    @EnvironmentObject var bookmarkHadithStore: BookmarkHadithStore
    
    private let placeholderHadith = Hadith(
        hadithNumber: "0",
        englishNarrator: "Narrated by Umar ibn Al-Khattab (RA)",
        hadithEnglish: "The reward of deeds depends upon the intentions, and every person will get the reward according to what they intended.",
        
        hadithArabic: "",
        headingArabic: ""
    )
    
    var body: some View {
        VStack {
            Text("Hadith of the Day")
                .padding(40)
                .font(.largeTitle)
                .bold()
                .background(RoundedRectangle(cornerRadius: 25).fill(Color.pink.opacity(0.1)))
            
            ScrollView {
                if let currentHadith = hadithStore.currentHadith {
                    hadithDisplay(currentHadith)
                } else {
                    hadithDisplay(placeholderHadith)
                }
            }
        }
        .onAppear {
            // Fetch hadith using UTC-based timestamp
            hadithStore.fetchHadith()
        }
    }
    
    @ViewBuilder
    private func hadithDisplay(_ hadith: Hadith) -> some View {
        VStack(spacing: 20) {
            Text(hadith.englishNarrator)
                .font(.headline)
                .bold()
            
            Text(hadith.hadithEnglish)
                .padding()
                .background(RoundedRectangle(cornerRadius: 25).fill(Color.green.opacity(0.2)))
            
            // Bookmark Button
            Button(action: {
                guard hadith.hadithNumber != "0" else {
                    print("Invalid Hadith number: \(hadith.hadithNumber)")
                    return
                }
                let bookmarkedHadith = BookmarkedHadith(
                    hadithNum: hadith.hadithNumber,
                    hadithText: hadith.hadithEnglish,
                    hadithNarrator: hadith.englishNarrator
                )
                bookmarkHadithStore.toggleBookmark(for: bookmarkedHadith)
            }) {
                Image(systemName: bookmarkHadithStore.isBookmarked(hadithNum: hadith.hadithNumber) ? "bookmark.fill" : "bookmark")
                    .foregroundColor(bookmarkHadithStore.isBookmarked(hadithNum: hadith.hadithNumber) ? .pink : .gray)
                    .font(.title2)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 25).fill(Color.green.opacity(0.1)))
    }
}

struct HadithView_Previews: PreviewProvider {
    static var bookmarkStore: BookmarkHadithStore = {
        let store = BookmarkHadithStore()
        store.bookmarkedHadiths = [
            BookmarkedHadith(hadithNum: "1", hadithText: "Al-Fatiha", hadithNarrator: "Narrated by Umar ibn Al-Khattab (RA)")
        ]
        return store
    }()
    
    static var previews: some View {
        HadithView()
            .environmentObject(bookmarkStore)
    }
}
