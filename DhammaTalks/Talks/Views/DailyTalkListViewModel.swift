//
//  DailyTalkListViewModel.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-19.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import Combine

class DailyTalkListViewModel: ObservableObject {

    private let calendar: Calendar
    private let talkDataService: TalkDataService
    let talkUserInfoService: TalkUserInfoService
    private let downloadManager: DownloadManager
    
    enum State {
        case initial
        case loading
        case loaded(sections: [TalkSectionViewModel])
        case error
    }

    let filters: [Filter] = [.downloaded, .favorited, .hasNotes]

    @Published var selectedCategory: DailyTalkCategory {
        didSet {
            AppSettings.selectedTalkCategory = selectedCategory
            if selectedYear < selectedCategory.startYear {
                selectedYear = selectedCategory.startYear
            }
        }
    }

    @Published var selectedFilter: Filter = .empty {
        didSet {
            self.talkSections = buildTalkSectionViewModels()
            self.state = .loaded(sections: talkSections)
        }
    }

    @Published var selectedYear: Int {
        didSet {
            AppSettings.selectedTalkYear = selectedYear
        }
    }

    @Published var showingAlert = false
    @Published var showingMinimumVersionAlert = false
    @Published private(set) var isFetchDataFinished = false
    @Published private(set) var state: State = .initial
    private var talkDataList: [TalkData] = []
    private(set) var talkSections: [TalkSectionViewModel] = []

    var currentYear: Int {
        calendar.currentYear
    }
    
    var isRefreshable: Bool {
        currentYear == selectedYear
    }
    
    var years: [Int] {
        Array(selectedCategory.startYear...currentYear).reversed()
    }
    
    var filterImageName: String {
        selectedFilter.imageName
    }
    
    var filterTitle: String {
        selectedFilter.title
    }

    init(talkDataService: TalkDataService, talkUserInfoService: TalkUserInfoService, downloadManager: DownloadManager, calendar: Calendar = .current) {
        self.talkDataService = talkDataService
        self.talkUserInfoService = talkUserInfoService
        self.downloadManager = downloadManager
        self.calendar = calendar
        self.selectedCategory = AppSettings.selectedTalkCategory ?? .evening
        self.selectedYear = AppSettings.selectedTalkYear ?? calendar.currentYear
    }
    
    func playRandomTalk() async -> String? {
        guard let randomSection = talkSections.randomElement() else { return nil }
        return await randomSection.talkRows.playRandom()
    }
    
    private func buildTalkSectionViewModels() -> [TalkSectionViewModel] {
        var talkSectionViewModelList: [TalkSectionViewModel] = []
        var currentTalkSection: TalkSectionViewModel?
        for talkData in self.talkDataList {
            guard let date = talkData.date else {
                continue
            }

            let sectionTitle = DateFormatter.talkSectionDateFormatter.string(from: date)
            let talkRowViewModel = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
            if currentTalkSection?.title == sectionTitle {
                if talkRowViewModel.applyFilter(selectedFilter) {
                    currentTalkSection?.addTalkRow(talkRowViewModel)
                }
            } else {
                if let talkSection = currentTalkSection, !talkSection.talkRows.isEmpty {
                    talkSectionViewModelList.append(talkSection)
                }
                currentTalkSection = TalkSectionViewModel(id: UUID().uuidString, title: sectionTitle)
                if talkRowViewModel.applyFilter(selectedFilter) {
                    currentTalkSection?.addTalkRow(talkRowViewModel)
                }
            }
        }
        
        if let talkSection = currentTalkSection, !talkSection.talkRows.isEmpty {
            talkSectionViewModelList.append(talkSection)
        }
        return talkSectionViewModelList
    }

    @MainActor
    func fetchData(searchText: String? = nil) async {

        func loadTalkDataList(talkDataList: [TalkData]) {
            self.talkDataList = talkDataList
            self.talkSections = buildTalkSectionViewModels()
            self.state = .loaded(sections: talkSections)
        }

        self.state = .loading
        
        let query = DailyTalkQuery(category: selectedCategory,
                                   year: selectedYear,
                                   searchText: searchText)
        do {
            let results = try await talkDataService.fetchYearlyTalks(query: query)
            loadTalkDataList(talkDataList: results)
        } catch TalkFetchError.belowMinimumVersion(let cachedResults) {
            loadTalkDataList(talkDataList: cachedResults)
            showingMinimumVersionAlert = true
        } catch TalkFetchError.error(_, let cachedResults) {
            loadTalkDataList(talkDataList: cachedResults)
        } catch {
            guard !error.isCancelError else {
                return
            }
            self.state = .error
            showingAlert = true
        }
    }
}
