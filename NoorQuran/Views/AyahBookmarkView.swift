//
//  AyahBookmarkView.swift
//  NoorQuran
//
//  Created by Tes Essa on 12/4/24.
//

import SwiftUI
//Text(currentHadith.englishNarrator)
//Text(currentHadith.hadithEnglish)
//    .padding()
//    .background(RoundedRectangle(cornerRadius: 25).fill(Color.green.opacity(0.2)))
////                        Text("Narrated by: \(currentHadith.englishNarrator)")
//}
//.padding(10)
//.padding(.top)
//.padding(.bottom)
//.font(.headline)
//.bold()
//.background(RoundedRectangle(cornerRadius: 25).fill(Color.green.opacity(0.2)))

struct AyahBookmarkView: View{
@EnvironmentObject var bookmarkAyahStore: BookmarkAyahStore
    var body: some View {
        if bookmarkAyahStore.bookmarkedAyahs.isEmpty {
            // Display a message when no data is available
            Text("No bookmarked ayahs to display.")
                .foregroundColor(.gray)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
        } else {
            ScrollView {
                ForEach(bookmarkAyahStore.bookmarkedAyahs) { ayah in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Surah \(ayah.surah): \(ayah.surahName)")
                                        .font(.headline)
                                    Text("Ayah \(ayah.ayah)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(ayah.text)
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
struct AyahBookmarkView_Previews: PreviewProvider {
    static var bookmarkStore: BookmarkAyahStore = {
        let store = BookmarkAyahStore()
        store.bookmarkedAyahs = [
            BookmarkedAyah(surah: 1, surahName: "Al-Fatiha", ayah: 1, text: "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ"),
            BookmarkedAyah(surah: 2, surahName: "Al-Baqara", ayah: 255, text: "")
        ]
        return store
    }()
    static var previews: some View {
        AyahBookmarkView()
            .environmentObject(bookmarkStore)
    }
}
