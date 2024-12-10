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
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("Green"), Color("AccentGreen")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            if bookmarkHadithStore.bookmarkedHadiths.isEmpty {
                VStack {
                    Text("No Bookmarked Hadiths")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .multilineTextAlignment(.center)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(bookmarkHadithStore.bookmarkedHadiths) { hadith in
                            HadithItemView(hadith: hadith)
                                .environmentObject(bookmarkHadithStore)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct HadithItemView: View {
    @EnvironmentObject var bookmarkHadithStore: BookmarkHadithStore
    let hadith: BookmarkedHadith

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(hadith.hadithNarrator):")
                .font(.headline)
                .foregroundColor(.white)
                .bold()

            Text(hadith.hadithText)
                .font(.body)
                .foregroundColor(.black)
                .bold()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("AccentPink").opacity(0.8))
                )

            Button(action: {
                bookmarkHadithStore.toggleBookmark(for: hadith)
            }) {
                Image(systemName: bookmarkHadithStore.isBookmarked(hadithNum: hadith.hadithNum) ? "bookmark.fill" : "bookmark")
                    .foregroundColor(bookmarkHadithStore.isBookmarked(hadithNum: hadith.hadithNum) ? Color("Pink") : .white)
                    .font(.title2)
            }
            .padding(.top)
        }
        .padding()
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
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}

struct HadithBookmarkView_Previews: PreviewProvider {
    static var bookmarkStore: BookmarkHadithStore = {
          let store = BookmarkHadithStore()
          store.bookmarkedHadiths = [
              BookmarkedHadith(hadithNum: "1", hadithText: "Indeed, deeds are judged by intentions.", hadithNarrator: "Narrated by Umar ibn Al-Khattab (RA)")
          ]
          return store
      }()
    static var previews: some View {
        HadithBookmarkView()
            .environmentObject(bookmarkStore)
    }
}
