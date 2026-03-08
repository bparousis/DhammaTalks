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
    @EnvironmentObject private var playlistService: PlaylistService

    @State private var selection: String? = nil
    @State private var showSettings: Bool = false
    private static let dailyTalksTag = "dailyTalks"
    private static let favoritesTag = "favorites"
    private static let playlistsTag = "playlists"

    private var dailyTalksView: some View {
        DailyTalkListView(talkDataService: talkDataService, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager, playlistService: playlistService)
            .onAppear {
                AppSettings.talkGroupSelection = Self.dailyTalksTag
            }
    }

    private var favoritesView: some View {
        FavoritesListView(talkUserInfoService: talkUserInfoService, downloadManager: downloadManager, playlistService: playlistService)
            .onAppear {
                AppSettings.talkGroupSelection = Self.favoritesTag
            }
    }
    
    private var playlistSelectorView: some View {
        PlaylistSelectorView(playlistService: playlistService, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
            .onAppear {
                AppSettings.talkGroupSelection = Self.playlistsTag
            }
    }

    private var widthPercentage: CGFloat {
        isIpad ? 0.20 : 0.475
    }
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: isIpad ? 4 : 2)
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                        let width = geo.size.width * widthPercentage
                        makeMainSection(columnWidth: width)
                        if let talkSeriesList = TalkDataService.talkSeriesList {
                            Spacer()
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
        ZStack(alignment: .bottom) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode:.fill)

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.6)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(12)
        }
        .frame(width: width, height:100, alignment:.center)
        .clipShape(RoundedRectangle(cornerRadius: 18))
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

            NavigationLink(destination: playlistSelectorView, tag: Self.playlistsTag, selection: $selection)
            {
                makeCellView(title: "Playlists", image: "water9", width: columnWidth)
            }
            .id(Self.playlistsTag)
        }
    }
    
    private func makeTalkSeriesSection(talkSeriesList: [TalkSeries], columnWidth: CGFloat) -> some View {
        Section {
            ForEach(talkSeriesList) { talkSeries in
                let talkSeriesListView = TalkSeriesListView(talkSeries: talkSeries,
                                                            talkUserInfoService: talkUserInfoService,
                                                            downloadManager: downloadManager,
                                                            playlistService: playlistService)
                    .onAppear {
                        AppSettings.talkGroupSelection = talkSeries.title
                    }
                
                NavigationLink(destination: talkSeriesListView, tag: talkSeries.title, selection: $selection) {
                    makeCellView(title: talkSeries.title, image: talkSeries.image, width: columnWidth)
                }
                .id(talkSeries.title)
            }
        } header: {
            ZStack {
                HStack {
                    gradientLine
                    Text("Series")
                        .font(.system(size: 20))
                        .bold()
                    gradientLine
                }
            }
        }
    }
    
    private var gradientLine: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color(UIColor.systemBackground), .primary, Color(UIColor.systemBackground)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .padding()
    }
}
