//
//  TalkSeriesListViewModel.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-02-10.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation


class TalkSeriesListViewModel: ObservableObject {

    private let talkSeries: TalkSeries
    private let talkUserInfoService: TalkUserInfoService
    private let downloadManager: DownloadManager

    var title: String {
        talkSeries.title
    }
    
    var description: String {
        talkSeries.description
    }
    
    @Published private(set) var talkSections: [TalkSectionViewModel] = []
    
    init(talkSeries: TalkSeries, talkUserInfoService: TalkUserInfoService, downloadManager: DownloadManager) {
        self.talkSeries = talkSeries
        self.talkUserInfoService = talkUserInfoService
        self.downloadManager = downloadManager
    }
    
    func fetchData(searchText: String = "") {
        var talkSectionViewModelList: [TalkSectionViewModel] = []
        let searchTextLowerCased = searchText.lowercased()
        for section in talkSeries.sections {
            let sectionViewModel = TalkSectionViewModel(id: section.id, title: section.title)
            
            var talkRows: [TalkData] = section.talks
            if !searchText.isEmpty {
                talkRows = talkRows.filter { $0.title.lowercased().contains(searchTextLowerCased) }
            }
            
            if !talkRows.isEmpty {
                sectionViewModel.talkRows = talkRows.map {
                    let talkRowViewModel = TalkRowViewModel(talkData: $0, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
                    talkRowViewModel.dateStyle = .full
                    return talkRowViewModel
                }
                
                talkSectionViewModelList.append(sectionViewModel)
            }   
        }
        self.talkSections = talkSectionViewModelList
    }
}
