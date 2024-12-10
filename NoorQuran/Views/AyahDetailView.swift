//
//  AyahDetailView.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/25/24.
//

import SwiftUI

struct AyahDetailView: View {
    var ayah: Ayah
    var surahDetail: SurahDetail
    @ObservedObject var surahStore = SurahStore()
    @State private var recitationView = false
    @State private var translationText: String?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var whiteBoxHeight: CGFloat = 0 //for rec view box
    @State private var count = 0 // count for button
    let maxCount = 10
    
    var body: some View {
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("Green"), Color("AccentGreen")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    Text("Surah \(surahDetail.englishName) (\(surahDetail.name))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .scaledToFit()
                        .padding()
                    
                    Text("Ayah \(ayah.numberInSurah) of Surah \(surahDetail.number)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)

                    // ayah text w/ overlay when recitationView is true
                    ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(radius: 5)
                                    .overlay(
                                        // tracking height of white box
                                        GeometryReader { geometry in
                                            Color.clear
                                                .onAppear {
                                                    // Store the height of the white box
                                                    self.whiteBoxHeight = geometry.size.height
                                                }
                                        }
                                    )

                                // ayah Text
                                HStack {
                                    Spacer()
                                    Text(ayah.text)
                                        .font(.title3)
                                        .multilineTextAlignment(.trailing)
                                        .padding(.all)
                                        .lineSpacing(5)
                                }

                                if recitationView {
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(height: whiteBoxHeight)
                                        .cornerRadius(10)
                                        .padding(.all)
                                }
                            }
                            .padding(.bottom, 20)
                    
              
                    Divider()
                        .padding(.horizontal, 20)
                
                    Button(action: {
                        withAnimation {
                            recitationView.toggle()
                            if recitationView { startCounting() }
                        }
                    }) {
                        Text(recitationView ? "Hide Recitation View" : "Practice Recitation")
                            .padding()
                            .background(Color("Pink").opacity(0.8))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .cornerRadius(10)
                    }

                    if recitationView {
                        Button(action: {
                            incrementCount()
                            
                            if count >= maxCount {
                                count = 0 //resets the count
                                recitationView.toggle() //switches back
                            }
                        }) {
                            Text("\(count)/\(maxCount)")
                                .padding()
                                .background(Color("Pink").opacity(0.8))
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .cornerRadius(10)
                        }
                        .disabled(count >= maxCount)
                    }

                    if isLoading {
                        ProgressView("Loading translation...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        VStack {
                            Text("Translation")
                            Text(translationText ?? "Translation not available")
                                .font(.body)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 15).fill(Color("AccentPink").opacity(0.8)))
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationBarTitle("Ayah Detail", displayMode: .inline)
                .onAppear {
                    fetchTranslation()
                }
            }
        }
    }
    
    private func fetchTranslation() {
        surahStore.fetchAyahTranslation(surahNumber: surahDetail.number, ayahNumber: ayah.numberInSurah) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translation):
                    self.translationText = translation
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = "Failed to load translation: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func incrementCount() {
        if count < maxCount {
            count += 1
        }
    }
    
    private func startCounting() {
        count = 0
    }
}

struct AyahDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let testAyah = Ayah(
            number: 1,
            text: "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ\n",
            numberInSurah: 1
        )
        
        let surahTest = SurahDetail(
            number: 1,
            name: "سُورَةُ ٱلْفَاتِحَةِ",
            englishName: "Al-Fatiha",
            englishNameTranslation: "The Opening",
            numberOfAyahs: 7,
            revelationType: "Meccan",
            ayahs: [testAyah]
        )
        
        AyahDetailView(ayah: testAyah, surahDetail: surahTest)
    }
}
