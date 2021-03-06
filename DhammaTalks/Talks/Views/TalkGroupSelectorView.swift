//
//  TalkSeriesSelectorView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-20.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import SwiftUI

struct TalkGroupSelectorView: View {

    @EnvironmentObject private var talkUserInfoService: TalkUserInfoService
    @EnvironmentObject private var downloadManager: DownloadManager

    @State private var selection: String? = nil
    @State private var showSettings: Bool = false
    private static let dailyTalksTag = "dailyTalks"
    private static let favoritesTag = "favorites"
    private let dailyTalkListViewModel: DailyTalkListViewModel
    private let favoritesListViewModel: FavoritesListViewModel

    private var dailyTalksView: some View {
        DailyTalkListView(viewModel: dailyTalkListViewModel)
            .onAppear {
                AppSettings.talkGroupSelection = Self.dailyTalksTag
            }
    }

    private var favoritesView: some View {
        FavoritesListView(viewModel: favoritesListViewModel)
            .onAppear {
                AppSettings.talkGroupSelection = Self.favoritesTag
            }
    }

    private var widthPercentage: CGFloat {
        isIpad ? 0.20 : 0.475
    }
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: isIpad ? 4 : 2)
    }
    
    init(dailyTalkListViewModel: DailyTalkListViewModel, favoritesListViewModel: FavoritesListViewModel) {
        self.dailyTalkListViewModel = dailyTalkListViewModel
        self.favoritesListViewModel = favoritesListViewModel
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                        let width = geo.size.width * widthPercentage
                        makeMainSection(columnWidth: width)
                        
                        if let talkSeriesList = TalkDataService.talkSeriesList {
                            makeTalkSeriesSection(talkSeriesList: talkSeriesList, columnWidth: width)
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(AppSettings.talkGroupSelection)
                        // If selection is nil then first time we're loading screen without a selection.  Therefore, we check
                        // to see if one exists from before and set it.  Otherwise, if onAppear gets triggered and selection is
                        // non-nil then we clear the previous stored selection.
                        if selection == nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                selection = AppSettings.talkGroupSelection
                            }
                        } else {
                            AppSettings.talkGroupSelection = nil
                        }
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .tint(.primary)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
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
                .foregroundColor(.primary)
                .frame(width: width, height:75, alignment:.top)
        }
    }
    
    private func makeMainSection(columnWidth: CGFloat) -> some View {
        Section {
            NavigationLink(destination: dailyTalksView, tag: Self.dailyTalksTag, selection: $selection)
            {
                makeCellView(title: "Daily Talks", image: "water8", width: columnWidth)
            }
            .id(Self.dailyTalksTag)
            
            NavigationLink(destination: favoritesView, tag: Self.favoritesTag, selection: $selection)
            {
                makeCellView(title: "Favorites", image: "leaves", width: columnWidth)
            }
            .id(Self.favoritesTag)
        }
    }
    
    private func makeTalkSeriesSection(talkSeriesList: [TalkSeries], columnWidth: CGFloat) -> some View {
        Section {
            ForEach(talkSeriesList) { talkSeries in
                let viewModel = TalkSeriesListViewModel(talkSeries: talkSeries, talkUserInfoService: talkUserInfoService,
                                                        downloadManager: downloadManager)
                let talkSeriesListView = TalkSeriesListView(viewModel: viewModel)
                    .onAppear {
                        AppSettings.talkGroupSelection = talkSeries.title
                    }
                
                NavigationLink(destination: talkSeriesListView, tag: talkSeries.title, selection: $selection) {
                    makeCellView(title: talkSeries.title, image: talkSeries.image, width: columnWidth)
                }
                .id(talkSeries.title)
            }
        } header: {
            Text("Talk Series")
                .font(.system(size: 20))
                .bold()
        }
    }
}
