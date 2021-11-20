//
//  TalkSeriesSelectorView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-20.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import SwiftUI

struct TalkSeriesSelectorView: View {
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private let talkSeriesList: [TalkSeries]

    init(talkSeriesList: [TalkSeries]) {
        self.talkSeriesList = talkSeriesList
    }

    var body: some View {
        GeometryReader { geo in
            LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                ForEach(talkSeriesList) { talkSeries in
                    NavigationLink(destination: TalkSeriesListView(talkSeries:talkSeries)) {
                        ZStack {
                            let width = geo.size.width * 0.475
                            Image(talkSeries.image)
                                .resizable()
                                .frame(width: width, height:100, alignment:.center)
                                .aspectRatio(contentMode:.fill)
                                .cornerRadius(20)
                            Text(talkSeries.title)
                                .bold()
                                .font(.system(size:18, weight:.bold))
                                .foregroundColor(.white)
                                .frame(width: width, height:100, alignment:.center)
                        }
                    }
                }
            }
        }
        .navigationTitle("Collections")
    }
}
