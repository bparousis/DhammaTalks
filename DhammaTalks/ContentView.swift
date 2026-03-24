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
    @EnvironmentObject private var downloadManager: DownloadManager
    @EnvironmentObject private var playlistService: PlaylistService

    var body: some View {
        
        NavigationView {
            TalkGroupSelectorView()
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
