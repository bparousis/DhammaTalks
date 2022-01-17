//
//  ContentView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-11.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import SwiftUI
import AVFoundation

struct ContentView: View {

    @EnvironmentObject private var talkDataService: TalkDataService
    @EnvironmentObject private var talkUserInfoService: TalkUserInfoService

    var body: some View {
        NavigationView {
            TalkGroupSelectorView()
                .environmentObject(talkDataService)
                .environmentObject(talkUserInfoService)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
