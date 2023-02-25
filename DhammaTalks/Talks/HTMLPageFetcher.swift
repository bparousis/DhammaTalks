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
    private let calendar: Calendar
    
    init(urlSession: URLSession = .shared,
         fileStorage: FileStorage = LocalFileStorage(fileManager: .default),
         calendar: Calendar = .current)
    {
        self.urlSession = urlSession
        self.fileStorage = fileStorage
        self.calendar = calendar
    }
    
    /// Since HTML page from past years will never change, since all those talks have been conducted the app has those pages stored and uses
    /// them instead avoid fetching from the net.  We only really need to go to the net for the current year, since those talks are always updating.
    private func checkForCachedPage(_ category: DailyTalkCategory, year: Int) async -> [TalkData]? {
        guard let htmlFileURL = Bundle.main.url(forResource: category.cachedFileNameForYear(year), withExtension: "html") else {
            return nil
        }
        
        do {
            return try await talkDataFromURL(htmlFileURL, category: category, year: year)
        } catch {
            return nil
        }
    }

    func getYearlyHTMLForCategory(_ category: DailyTalkCategory, year: Int) async throws -> [TalkData] {
        
        if year != calendar.currentYear, let cachedData = await checkForCachedPage(category, year: year) {
            return cachedData
        }

        // Adding query parameter for cache busting, to avoid getting a CDN cached page.  Not ideal, since it
        // means we can't use URLCache since quwery changes each time.
        guard let talkURL = urlForCategory(category, year: year) else {
            throw HTMLPageFetcherError.invalidURL
        }

        do {
            return try await talkDataFromURL(talkURL, category: category, year: year)
        } catch {
            let url = fileStorage.createURL(for: cacheFilenameFromURL(talkURL))
            return try await talkDataFromURL(url, category: category, year: year)
        }
    }
    
    private func urlForCategory(_ category: DailyTalkCategory, year: Int) -> URL? {
        if year == calendar.currentYear {
            switch category {
            case .short:
                return URL(string: "https://www.dhammatalks.org/mp3_short_index_current.html")
            case .evening:
                return URL(string: "https://www.dhammatalks.org/mp3_index_current.html")
            }
        } else {
            return URL(string:"\(HTMLPageFetcher.archivePath)/\(category.directoryForYear(year))?q=\(UUID().uuidString)")
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
    
    private func talkDataFromURL(_ url: URL, category: DailyTalkCategory, year: Int) async throws -> [TalkData] {
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
            throw HTMLPageFetcherError.failedToRetrieve
        }
        
        let document = try SwiftSoup.parse(html)
        try document.select("a").forEach { element in
            let hrefValue = try element.attr("href")
            if let audioData = audioFileNameParser.parseFilenameWithDate(hrefValue) {
                let url = "\(category.directoryForYear(year))/\(audioData.filename)"
                let talkData = TalkData(id: url, title: audioData.title, date: audioData.date, url: url)
                if year == calendar.currentYear {
                    talkDataList.append(talkData)
                } else {
                    talkDataList.insert(talkData, at: 0)
                }
            }
        }
        
        return talkDataList
    }
}
