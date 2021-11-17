//
//  MainView.swift
//  DhammaTalks
//
//  Created by Brendan Miller on 2021-11-06.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import SwiftUI
import CoreMedia




struct MainView: View {
    
    let talkSeriesList: [TalkSeries]? = {
        if let path = Bundle.main.path(forResource: "TalkSeriesList", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let talkSeriesList = try JSONDecoder().decode([TalkSeries].self, from: data)
                return talkSeriesList
            } catch {
                return nil
            }
        }
        return nil
    }()

    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    var body: some View {
        TabView {
            NavigationView {
                DailyTalkListView()
            }
            .tabItem {
                Label("Daily Talks", systemImage: "mic")
            }
            
            NavigationView {
                LazyVGrid(columns: columns, spacing: 20) {
                    if let talkSeriesList = talkSeriesList {
                        ForEach(talkSeriesList) { talkSeries in
                            NavigationLink(destination: TalkSeriesListView(title: talkSeries.title, talkDataList: talkSeries.talks)) {
                                VStack{
                                    Text(talkSeries.title)
                                        .bold()
                                        .font(.system(size:20, weight:.bold))
                                        .foregroundColor(Color("Colour 4"))
                                    Image(talkSeries.image)
                                        .resizable()
                                        .frame(width: 150, height:100, alignment:.center)
                                        .aspectRatio(contentMode:.fill)
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                }
            }
            .tabItem {
                Label("Talk Collections", systemImage: "square.grid.2x2")
            }
        }
        .navigationTitle("Dhammatalks")
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
