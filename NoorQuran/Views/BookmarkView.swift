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
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("Green"), Color("AccentGreen")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            VStack{
               Text("Bookmarks")
                   .font(.largeTitle)
    //               .font(.system(size: 50))
                   .padding(20)
                   .fontWeight(.bold)
                   .background(Capsule().fill(LinearGradient(gradient: Gradient(colors: [Color("AccentPink").opacity(0.8), Color("Pink").opacity(0.6)]), startPoint: .top, endPoint: .bottom)))
                   .foregroundColor(.white)
                
                Picker(selection: $selectedView, label: Text("Bookmarks")){
                    Text("Ayah Bookmarks")
                        .tag(1)
                    Text("Hadith Bookmarks")
                        .tag(2)
                }
    
                .pickerStyle(SegmentedPickerStyle())
                .padding()
               .colorMultiply(Color("AccentPink"))

               ViewContent(selectedView: selectedView)
                   .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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
