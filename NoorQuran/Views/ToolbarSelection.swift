//
//  ToolbarSelection.swift
//  NoorQuran
//
//  Created by Tes Essa on 10/21/24.
//

import Foundation
enum ToolbarSelection: CaseIterable, Identifiable{  //identifiable- [rovide id
    var id: Int {
        hashValue
    } //make hashable enums automatically conform,
    case homeModal, quranModal, hadithModal, bookmarkModal //for each button
}
