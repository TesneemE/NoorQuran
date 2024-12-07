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
    
    @State private var translationText: String?
    @State private var isLoading = true // Loading state
    @State private var errorMessage: String? // Error message
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Surah \(surahDetail.englishName) (\(surahDetail.name))")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Ayah \(ayah.numberInSurah) of Surah \(surahDetail.number)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(ayah.text)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            if isLoading {
                ProgressView("Loading translation...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                Text(translationText ?? "Translation not available")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Spacer()
        }
        .onAppear {
            fetchTranslation()
        }
        .padding()
        .navigationBarTitle("Ayah Detail", displayMode: .inline)
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

