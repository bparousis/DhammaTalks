//
//  TalkSectionHeader.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-16.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftUI

struct TalkSectionHeader: View {
    let title: String
    let talkCount: Int

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("talk-count \(talkCount)")
        }
    }
}
