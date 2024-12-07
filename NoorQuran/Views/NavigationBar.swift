//
//  NavigationBar.swift
//  NoorQuran
//
//  Created by Tes Essa on 10/21/24.
//
//tabview
import SwiftUI
struct ToolbarButton: View{
    let modal: ToolbarSelection
    private let modalButton: [
        ToolbarSelection: (text: String, imageName: String, ForegroundStyle: String)
    ] = [
    .homeModal: ("Home", "house", ".black"), .quranModal: ("Quran", "book", ".black"), .hadithModal: ("Hadith", "seal", ".black"), .bookmarkModal: ("Bookmark", "bookmark", ".black")
    ]
    var body: some View{
        if let text = modalButton[modal]?.text,
           let imageName = modalButton[modal]?.imageName {//getting modal
            VStack{
                Image(systemName: imageName)
                    .font(.largeTitle)
                Text(text)
            }
            .padding(.top)
        }
    } //each modal uses this view
}


struct NavigationBar: View {
    @Binding var modal: ToolbarSelection? //for current midal
    var body: some View {
        HStack{
            ForEach(ToolbarSelection.allCases){ selection in //calling it selection
          // dont need  id: \.self b/c already identifiable
                Button{
                    modal = selection
                } label:{
                    ToolbarButton(modal: selection)}
            } //Because the text label for the button is a custom view, rather than a string, you use the Button(action:label:) initializer
        }
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar(modal: .constant(.homeModal))
            .padding()
        
    }
}

