//
//  DailyTalkCategory.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-08.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

class HTMLPageFetcher {
    
    static let archivePath = "https://www.dhammatalks.org/Archive"
    
    enum HTMLPageFetcherError: Error {
        case invalidURL
        case failedToRetrieve
    }
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    /// Since HTML page from past years will never change, since all those talks have been conducted the app has those pages stored and uses
    /// them instead avoid fetching from the net.  We only really need to go to the net for the current year, since those talks are always updating.
    private func checkForCachedPage(_ category: DailyTalkCategory, year: Int) -> YearlyHTMLData? {
        guard let htmlFileURL = Bundle.main.url(forResource: category.cachedFileNameForYear(year), withExtension: "html") else {
            return nil
        }
        
        do {
            let htmlContent = try String(contentsOf: htmlFileURL)
            return YearlyHTMLData(html: htmlContent, talkCategory: category, year: year)
        } catch {
            return nil
        }
    }

    func getYearlyHTMLForCategory(_ category: DailyTalkCategory, year: Int) async -> Result<YearlyHTMLData, Error> {
        
        if let cachedData = checkForCachedPage(category, year: year) {
            return .success(cachedData)
        }

        guard let talkURL = URL(string:"\(HTMLPageFetcher.archivePath)/\(category.directoryForYear(year))") else {
            return .failure(HTMLPageFetcherError.invalidURL)
        }

        do {
            let (data, _) = try await urlSession.data(from: talkURL)
            guard let content = String(data: data, encoding: .utf8) else {
                return .failure(HTMLPageFetcherError.failedToRetrieve)
            }
            return .success(YearlyHTMLData(html: content, talkCategory: category, year: year))
        } catch {
            return .failure(error)
        }
    }
}
