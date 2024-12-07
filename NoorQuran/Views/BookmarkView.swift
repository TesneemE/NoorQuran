//
//  BookmarkView.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/30/24.
//

import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var bookmarkAyahStore: BookmarkAyahStore
    @EnvironmentObject var bookmarkHadithStore: BookmarkHadithStore
    @State private var selectedView = 1


    var body: some View {
       VStack{
           Text("Bookmarks")
               .font(.title)
//               .font(.system(size: 50))
               .padding(20)
            
            Picker(selection: $selectedView, label: Text("Bookmarks")){
                Text("Ayah Bookmarks")
                    .tag(1)
                Text("Hadith Bookmarks")
                    .tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

           // Embed the selected view
           ViewContent(selectedView: selectedView)
               .frame(maxWidth: .infinity, maxHeight: .infinity) // Adjust for flexible layout
       }
//       .navigationTitle("Bookmarks")
   }
}

struct ViewContent: View {
   let selectedView: Int

   @ViewBuilder
   var body: some View {
       switch selectedView {
       case 1:
           AyahBookmarkView()
       case 2:
           HadithBookmarkView()
       default:
           Text("Invalid Selection")
       }
   }
}



struct BookmarkView_Previews: PreviewProvider {
    static var bookmarkStore: BookmarkAyahStore = {
        let store = BookmarkAyahStore()
        store.bookmarkedAyahs = [
            BookmarkedAyah(surah: 1, surahName: "Al-Fatiha", ayah: 1, text: "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ"),
            BookmarkedAyah(surah: 2, surahName: "Al-Baqara", ayah: 255, text: "")
        ]
        return store
    }()
    static var bookmarkHStore: BookmarkHadithStore = {
        let store = BookmarkHadithStore()
        store.bookmarkedHadiths = [
            BookmarkedHadith(hadithNum: "1", hadithText: "Al-Fatiha", hadithNarrator: ""),
        ]
        return store
    }()
    static var previews: some View {
        BookmarkView()
            .environmentObject(bookmarkStore)
            .environmentObject(bookmarkHStore)
    }
}
