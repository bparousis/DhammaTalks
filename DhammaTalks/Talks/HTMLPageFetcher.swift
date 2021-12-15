//
//  DailyTalkCategory.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-08.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftSoup
import os.log

class HTMLPageFetcher {
    
    static let archivePath = "https://www.dhammatalks.org/Archive"
    
    enum HTMLPageFetcherError: Error {
        case invalidURL
        case failedToRetrieve
    }
    
    private let urlSession: URLSession
    private let fileStorage: FileStorage
    
    init(urlSession: URLSession = .shared, fileStorage: FileStorage = LocalFileStorage(fileManager: .default)) {
        self.urlSession = urlSession
        self.fileStorage = fileStorage
    }
    
    /// Since HTML page from past years will never change, since all those talks have been conducted the app has those pages stored and uses
    /// them instead avoid fetching from the net.  We only really need to go to the net for the current year, since those talks are always updating.
    private func checkForCachedPage(_ category: DailyTalkCategory, year: Int) async -> YearlyTalkData? {
        guard let htmlFileURL = Bundle.main.url(forResource: category.cachedFileNameForYear(year), withExtension: "html") else {
            return nil
        }
        
        let result = await talkDataFromURL(htmlFileURL, category: category, year: year)
        switch result {
        case .success(let data):
            return data
        case .failure:
            return nil
        }
    }

    func getYearlyHTMLForCategory(_ category: DailyTalkCategory, year: Int) async -> Result<YearlyTalkData, Error> {
        
        if let cachedData = await checkForCachedPage(category, year: year) {
            return .success(cachedData)
        }

        // Adding query parameter for cache busting, to avoid getting a CDN cached page.  Not ideal, since it
        // means we can't use URLCache since quwery changes each time.
        guard let talkURL = URL(string:"\(HTMLPageFetcher.archivePath)/\(category.directoryForYear(year))?q=\(UUID().uuidString)") else {
            return .failure(HTMLPageFetcherError.invalidURL)
        }

        let result = await talkDataFromURL(talkURL, category: category, year: year)
        switch result {
        case .success:
            return result
        case .failure:
            let url = fileStorage.createURL(for: cacheFilenameFromURL(talkURL))
            return await talkDataFromURL(url, category: category, year: year)
        }
    }
    
    private func cacheFilenameFromURL(_ url: URL) -> String {
        var cacheFilename = url.path
        cacheFilename = cacheFilename
            .suffix(from: String.Index(utf16Offset: "/Archive/".count, in: cacheFilename))
            .replacingOccurrences(of: "/", with: "_")
            .appending(".html")
        return cacheFilename
    }
    
    private func talkDataFromURL(_ url: URL, category: DailyTalkCategory, year: Int) async -> Result<YearlyTalkData, Error> {
        do {
            var talkDataList: [TalkData] = []
            let audioFileNameParser = AudioFileNameParser()

            let (data, _) = try await urlSession.data(from: url)
            let cacheFilename = cacheFilenameFromURL(url)
            do {
                // We save this for when we're in offline mode, so we can fallback and display the talks.  It's also
                // useful if we fail to retrieve the page for other reasons, it'll default back to this page.
                // Can't use URLCache, since our query changes due to cache busting strategy (see above).
                try fileStorage.saveData(data, withFilename: cacheFilename)
            } catch {
                Logger.fileStorage.error("Failed to save page cache '\(cacheFilename)': \(String(describing: error))")
            }

            guard let html = String(data: data, encoding: .utf8) else {
                return .failure(HTMLPageFetcherError.failedToRetrieve)
            }
            
            do {
                let document = try SwiftSoup.parse(html)
                try document.select("a").forEach { element in
                    let hrefValue = try element.attr("href")
                    if let (title, date) = audioFileNameParser.parseFileNameWithDate(hrefValue) {
                        let url = "\(category.directoryForYear(year))/\(hrefValue)"
                        let talkData = TalkData(id: url, title: title, date: date, url: url)
                        talkDataList.insert(talkData, at: 0)
                    }
                }
            } catch {
                return .failure(error)
            }

            return .success(YearlyTalkData(talkDataList: talkDataList, talkCategory: category, year: year))
        } catch {
            return .failure(error)
        }
    }
}
