//
//  TalkSeriesSelectorView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-20.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import SwiftUI

struct TalkGroupSelectorView: View {

    @EnvironmentObject private var talkDataService: TalkDataService
    @EnvironmentObject private var talkUserInfoService: TalkUserInfoService
    @EnvironmentObject private var downloadManager: DownloadManager

    @State private var selection: String? = nil
    private static let dailyTalksTag = "dailyTalks"
    private static let favoritesTag = "favorites"

    private var dailyTalksView: some View {
        DailyTalkListView(viewModel: DailyTalkListViewModel(talkDataService: talkDataService,
                                                            talkUserInfoService: talkUserInfoService,
                                                            downloadManager: downloadManager))
            .onAppear {
                AppSettings.talkGroupSelection = Self.dailyTalksTag
            }
    }

    private var favoritesView: some View {
        FavoritesListView(viewModel: FavoritesListViewModel(talkUserInfoService: talkUserInfoService, downloadManager: downloadManager))
            .onAppear {
                AppSettings.talkGroupSelection = Self.favoritesTag
            }
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                    let width = geo.size.width * 0.475
                    makeMainSection(columnWidth: width)
                    
                    if let talkSeriesList = TalkDataService.talkSeriesList {
                        makeTalkSeriesSection(talkSeriesList: talkSeriesList, columnWidth: width)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Image("dtLogo-transparent")
                        .resizable()
                        .frame(width: 35.0, height: 35.0)
                    Text("Dhamma Talks")
                        .font(.title)
                        .bold()
                }
            }
        }
        .onAppear {
            if selection == nil {
                selection = AppSettings.talkGroupSelection
            } else {
                AppSettings.talkGroupSelection = nil
            }
        }
    }
    
    private func makeCellView(title: String, image: String, width: CGFloat) -> some View {
        VStack {
            Image(image)
                .resizable()
                .frame(width: width, height:100, alignment:.center)
                .aspectRatio(contentMode:.fill)
                .cornerRadius(20)
            Text(title)
                .bold()
                .font(.system(size:18, weight:.bold))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 5.0, x: 5.0, y: 5.0)
                .frame(width: width, height:75, alignment:.top)
        }
    }
    
    private func makeMainSection(columnWidth: CGFloat) -> some View {
        Section {
            NavigationLink(destination: dailyTalksView, tag: Self.dailyTalksTag, selection: $selection)
            {
                makeCellView(title: "Daily Talks", image: "water8", width: columnWidth)
            }
            
            NavigationLink(destination: favoritesView, tag: Self.favoritesTag, selection: $selection)
            {
                makeCellView(title: "Favorites", image: "leaves", width: columnWidth)
            }
        }
    }
    
    private func makeTalkSeriesSection(talkSeriesList: [TalkSeries], columnWidth: CGFloat) -> some View {
        Section {
            ForEach(talkSeriesList) { talkSeries in
                let talkSeriesListView = TalkSeriesListView(talkSeries:talkSeries, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
                    .onAppear {
                        AppSettings.talkGroupSelection = talkSeries.title
                    }
                
                NavigationLink(destination: talkSeriesListView, tag: talkSeries.title, selection: $selection) {
                    makeCellView(title: talkSeries.title, image: talkSeries.image, width: columnWidth)
                }
            }
        } header: {
            Text("Talk Series")
                .font(.system(size: 20))
                .bold()
        }
    }
}
