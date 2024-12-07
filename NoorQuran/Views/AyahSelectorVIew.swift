//
//  AyahSelectorVIew.swift
//  NoorQuran
//
//  Created by Tes Essa on 10/17/24.
//

import SwiftUI

struct AyahSelectorVIew: View {
    var body: some View {
        List {
            Text("abc")
            Text("def")
        }
        .border(Color.yellow, width: 3)
        .background(Color.blue)
        .padding(10)
//        .border(Color.red, width: 3)
    }
}

struct AyahSelectorVIew_Previews: PreviewProvider {
    static var previews: some View {
        AyahSelectorVIew()
    }
}
