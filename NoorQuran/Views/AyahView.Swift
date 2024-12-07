//
//  AyahView.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/25/24.
//

import SwiftUI
//struct AyahView: View{
//    var ayah: Ayah
//
//       var body: some View {
//           VStack {
//               Text("Ayah \(ayah.number): \(ayah.text)")
//                   .font(.title2)
//                   .padding()
//
//               HStack {
//                   Button("Play Audio") {
//                       // Code to play the Ayah's audio
//                   }
//                   .padding()
//
//                   Button("Bookmark") {
//                       // Code to add to bookmarks
//                   }
//                   .padding()
//               }
//               .padding()
//           }
//       }
//   }
//}?HEREE down
//struct AyahView: View {
//    var surahNum: Int
//    var ayahNum: Int
//
//    @StateObject private var ayahStore = AyahStore()
////    var surah: Surah
//    var body: some View {
//        ScrollView {
//            VStack {
//                if let ayah = ayahStore.ayahs.first {
//                    HStack{
//                        Text(ayah.surah.englishName)
//                        Spacer()
//                        Text(ayah.surah.name)
//                    }
//                    .font(.title)
//                    .padding(.bottom, 10)
//
//                    Text(ayah.text)
//                        .font(.title)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                } else {
//                    ProgressView("Loading...")
//                        .onAppear {
//                            ayahStore.loadAyahs(surahNum: surahNum, ayahNum: ayahNum)
//                        }
//                }
//            }
//            .navigationTitle("Surah \(surahNum), Ayah \(ayahNum)")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//HEREEE up
////struct AyahView: View {
////    @ObservedObject var ayahStore = AyahStore()
////
////    var surahNum: Int
////    var ayahNum: Int
////
////    var body: some View {
////        VStack {
////            if let ayah = ayahStore.ayahs.first {
////                Text(ayah.text)
////                    .font(.title)
////                    .padding()
////                // Add play audio button or any other UI here
////            } else {
////                Text("Loading...")
////            }
////        }
////        .onAppear {
////            ayahStore.loadAyahs(surahNum: surahNum, ayahNum: ayahNum)
////        }
////    }
////}
//
//
//struct AyahView: View {
//    var surahNum: Int
//    var ayahNum: Int
////    var ayah: Ayah
//
////    @State private var ayah: Ayah? = nil  // Store the Ayah data
//    @StateObject var ayah_store=AyahStore()
//    var body: some View {
//        VStack {
//            if let ayah = ayah {
//                // Display the verse text
//                Text(ayah.text)
//                    .font(.title)
//                    .padding()
//
//                // You can add more UI here, such as an audio player for the verse
//            } else {
//                Text("Loading verse...")
//                    .onAppear {
//                        loadAyahs()
//                    }
//            }
//        }
//        .navigationTitle("Surah \(surahNum), Ayah \(ayahNum)")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//
//    func loadAyah() {
//        let urlString = "https://api.alquran.cloud/v1/ayah/\(surahNum):\(ayahNum)/ar.alafasy"
//        
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("Error fetching data: \(error)")
//                return
//            }
//            
//            guard let data = data else {
//                print("No data received")
//                return
//            }
//            
//            do {
//                let decoder = JSONDecoder()
//                let response = try decoder.decode(AyahResponse.self, from: data)
//                DispatchQueue.main.async {
//                    self.ayah = response.data.first  // Load the first Ayah (only one should be returned)
//                }
//            } catch {
//                print("Error decoding JSON: \(error)")
//            }
//        }.resume()
//    }
//}

//??HEREE
//
//struct AyahView_Previews: PreviewProvider {
//    static var previews: some View {
//        AyahView(surahNum:1, ayahNum:1)
//    }
//}
