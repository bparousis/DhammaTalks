//
//  TalkSectionViewModel.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-02-03.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation

class TalkSectionViewModel: Identifiable {
    let id: String
    let title: String
    var talkRows: [TalkRowViewModel] = []

    init(id: String, title: String? = nil) {
        self.id = id
        self.title = title ?? ""
    }

    func addTalkRow(_ talkRow: TalkRowViewModel) {
        talkRows.append(talkRow)
    }
}



