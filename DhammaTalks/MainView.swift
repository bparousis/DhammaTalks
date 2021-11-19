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

    let columns = [
        GridItem(.adaptive(minimum: 150)),
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
                LazyVGrid(columns: columns, spacing: 10) {
                    if let talkSeriesList = TalkDataService.talkSeriesList {
                        ForEach(talkSeriesList) { talkSeries in
                            NavigationLink(destination: TalkSeriesListView(talkSeries:talkSeries)) {
                                ZStack{
                                    Image(talkSeries.image)
                                        .resizable()
                                        .frame(width: 200, height:100, alignment:.center)
                                        .aspectRatio(contentMode:.fill)
                                        .cornerRadius(20)
                                    Text(talkSeries.title)
                                        .bold()
                                        .font(.system(size:18, weight:.bold))
                                        .foregroundColor(.white)
                                        .frame(width: 180, height:100, alignment:.center)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Collections")
            }
            .tabItem {
                Label("Collections", systemImage: "square.grid.2x2")
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
