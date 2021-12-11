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
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        TabView {
            NavigationView {
                DailyTalkListView(viewModel: DailyTalkListViewModel(talkDataService: TalkDataService(),
                                                                    talkUserInfoService: TalkUserInfoService(managedObjectContext: managedObjectContext)))
            }
            .tabItem {
                Label("Daily Talks", systemImage: "mic")
            }
            
            NavigationView {
                if let talkSeriesList = TalkDataService.talkSeriesList {
                    TalkSeriesSelectorView(talkSeriesList: talkSeriesList, talkUserInfoService: TalkUserInfoService(managedObjectContext: managedObjectContext))
                } else {
                    // It's not expected that this would ever be shown, since TalkDataService.talkSeriesList should
                    // load talk series from JSON file and display it in TalkSeriesSelectorView.
                    Text("No talk collections found")
                }
            }
            .tabItem {
                Label("Collections", systemImage: "square.grid.2x2")
            }
            
            NavigationView {
                FavoritesListView(viewModel: FavoritesListViewModel(talkUserInfoService: TalkUserInfoService(managedObjectContext: managedObjectContext)))
            }
            .tabItem {
                Label("Favorites", systemImage: "star.fill")
            }
        }
        .navigationTitle("Dhammatalks")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
