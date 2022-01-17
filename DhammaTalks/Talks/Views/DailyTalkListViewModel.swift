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

    @Published var selectedCategory: DailyTalkCategory {
        didSet {
            AppSettings.selectedTalkCategory = selectedCategory
            if selectedYear < selectedCategory.startYear {
                selectedYear = selectedCategory.startYear
            }
        }
    }

    @Published var selectedYear: Int {
        didSet {
            AppSettings.selectedTalkYear = selectedYear
        }
    }
    @Published var showingAlert = false
    @Published private(set) var talkSections: [TalkSection] = []
    @Published private(set) var isFetchDataFinished = false

    var currentYear: Int {
        calendar.currentYear
    }
    
    var years: [Int] {
        Array(selectedCategory.startYear...currentYear).reversed()
    }
    
    init(talkDataService: TalkDataService, talkUserInfoService: TalkUserInfoService, calendar: Calendar = .current) {
        self.talkDataService = talkDataService
        self.talkUserInfoService = talkUserInfoService
        self.calendar = calendar
        self.selectedCategory = AppSettings.selectedTalkCategory ?? .evening
        self.selectedYear = AppSettings.selectedTalkYear ?? calendar.currentYear
    }
    
    @MainActor
    func fetchData() async {
        
        defer {
            isFetchDataFinished = true
        }

        isFetchDataFinished = false
        
        let result = await talkDataService.fetchYearlyTalks(category: selectedCategory, year: selectedYear)
        switch result {
        case .success(let talkSections):
            self.talkSections = talkSections
        case .failure(let error):
            guard !error.isCancelError else {
                return
            }
            
            if (error as NSError).code != URLError.cancelled.rawValue {
                showingAlert = true
            }
        }
    }
}
