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
    @EnvironmentObject private var talkUserServiceInfo: TalkUserInfoService

    private var dailyTalksView: some View {
        NavigationView {
            DailyTalkListView(viewModel: DailyTalkListViewModel(talkDataService: talkDataService,
                                                                talkUserInfoService: talkUserServiceInfo))
        }
        .tabItem {
            Label("Daily Talks", systemImage: "mic")
        }
    }

    private var collectionsView: some View {
        NavigationView {
            if let talkSeriesList = TalkDataService.talkSeriesList {
                TalkSeriesSelectorView(talkSeriesList: talkSeriesList, talkUserInfoService: talkUserServiceInfo)
            } else {
                // It's not expected that this would ever be shown, since TalkDataService.talkSeriesList should
                // load talk series from JSON file and display it in TalkSeriesSelectorView.
                Text("No talk collections found")
            }
        }
        .tabItem {
            Label("Collections", systemImage: "square.grid.2x2")
        }
    }

    private var favoritesView: some View {
        NavigationView {
            FavoritesListView(viewModel: FavoritesListViewModel(talkUserInfoService: talkUserServiceInfo))
        }
        .tabItem {
            Label("Favorites", systemImage: "star.fill")
        }
    }

    var body: some View {
        TabView {
            dailyTalksView
            collectionsView
            favoritesView
        }
        .navigationTitle("Dhammatalks")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
