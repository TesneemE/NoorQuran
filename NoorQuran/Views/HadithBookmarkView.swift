//
//  HadithBookmarkView.swift
//  NoorQuran
//
//  Created by Tes Essa on 12/4/24.
//

import SwiftUI

struct HadithBookmarkView: View {
    @EnvironmentObject var bookmarkHadithStore: BookmarkHadithStore
    var body: some View {
        if bookmarkHadithStore.bookmarkedHadiths.isEmpty {
            // Display a message when no data is available
            Text("No bookmarked hadiths to display.")
                .foregroundColor(.gray)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
        } else {
            ScrollView {
                ForEach(bookmarkHadithStore.bookmarkedHadiths) { hadith in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(hadith.hadithNarrator)
                                        .font(.headline)
                                    Text(hadith.hadithText)
                                        .font(.headline)
                                        .background(RoundedRectangle(cornerRadius: 25).fill(Color.green.opacity(0.2)))
                                }
                                .padding(.vertical, 5)
                    .padding(10)
                    .padding(.top)
                    .padding(.bottom)
                    .font(.headline)
                    .bold()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.green.opacity(0.2)))
                            }
                        }
                    }
                }
    }

struct HadithBookmarkView_Previews: PreviewProvider {
    static var bookmarkStore: BookmarkHadithStore = {
        let store = BookmarkHadithStore()
        store.bookmarkedHadiths = [
            BookmarkedHadith(hadithNum: "1", hadithText: "Al-Fatiha", hadithNarrator: ""),
        ]
        return store
    }()
    static var previews: some View {
        HadithBookmarkView()
            .environmentObject(bookmarkStore)
    }
}
