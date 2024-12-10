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
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("Green"), Color("AccentGreen")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            VStack {
                Text("Hadith of the Day")
                    .padding(40)
                
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 25).fill(           LinearGradient(gradient: Gradient(colors: [Color("AccentPink").opacity(0.8), Color("Pink").opacity(0.6)]), startPoint: .top, endPoint: .bottom)))
                    .shadow(radius: 5)
                
                ScrollView {
                    if let currentHadith = hadithStore.currentHadith {
                        hadithDisplay(currentHadith)
                            .padding(.top,20)
                    } else {
                        hadithDisplay(placeholderHadith)
                            .padding(.top,20)
                    }
                }
            }
            .padding(.top)
            .onAppear {
                hadithStore.fetchHadith()
            }
        .padding()
        }
    }
    
    @ViewBuilder
    private func hadithDisplay(_ hadith: Hadith) -> some View {
        VStack(spacing: 20) {
            Text(hadith.englishNarrator)
                .font(.title3)
                .bold()
                .foregroundColor(.white)
            
            Text(hadith.hadithEnglish)
                .padding(.all)
                .font(.title3)

                .background(RoundedRectangle(cornerRadius: 25).fill(Color("AccentPink").opacity(0.8)))
                .foregroundColor(.white)
                .fontWeight(.bold)
            
            if !hadith.hadithArabic.isEmpty {
                Text(hadith.hadithArabic)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.trailing)
                    .padding(.all)
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color("AccentPink").opacity(0.8))) 
                    .foregroundColor(.white)
            }
            
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
                    .foregroundColor(bookmarkHadithStore.isBookmarked(hadithNum: hadith.hadithNumber) ? Color("Pink") : .white)
                    .font(.title2)
            }
            .padding(.top)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 25).fill(LinearGradient(gradient: Gradient(colors: [Color("AccentPink").opacity(0.8), Color("Pink").opacity(0.6)]), startPoint: .top, endPoint: .bottom)))
        .shadow(radius: 5)
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
