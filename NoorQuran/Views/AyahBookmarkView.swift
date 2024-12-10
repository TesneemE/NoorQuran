//
//  AyahBookmarkView.swift
//  NoorQuran
//
//  Created by Tes Essa on 12/4/24.
//

import SwiftUI

struct AyahBookmarkView: View {
    @EnvironmentObject var bookmarkAyahStore: BookmarkAyahStore
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("Green"), Color("AccentGreen")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            if bookmarkAyahStore.bookmarkedAyahs.isEmpty {
                Text("No bookmarked ayahs to display.")
                    .foregroundColor(.black)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(bookmarkAyahStore.bookmarkedAyahs) { ayahs in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Surah \(ayahs.surah): \(ayahs.surahName)")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("Ayah \(ayahs.ayah)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                // ayah Text
                                Text(ayahs.text)
                                    .font(.body)
                                    .bold()
                                    .fontWeight(.medium)
                                    .padding()
                                    .foregroundColor(.black)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color("AccentPink").opacity(0.8))
                                    )
                                Button(action: {
                                    bookmarkAyahStore.toggleBookmark(for: ayahs)
                                }) {
                                    Image(systemName: bookmarkAyahStore.isBookmarked(surah: ayahs.surah, ayah: ayahs.ayah) ? "bookmark.fill" : "bookmark")
                                        .foregroundColor(bookmarkAyahStore.isBookmarked(surah: ayahs.surah, ayah: ayahs.ayah) ? Color("Pink") : .gray)
                                }
                            }
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color("AccentPink").opacity(0.8), Color("Pink").opacity(0.6)]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .shadow(radius: 5)
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal, 10)
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
