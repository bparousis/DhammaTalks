//
//  DhammaTalkAPI.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2023-10-28.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import Foundation
import os.log

class DhammaTalkAPI: TalkFetcher {
    
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

    func fetchTalkCollection(for talkCategory: DailyTalkCategory, year: Int) async -> [TalkData] {
        guard let apiKey = Bundle.main.infoDictionary?["DT_API_KEY"] as? String else {
            return await fetchCachedResults(for: talkCategory, year: year)
        }

        let url = URL(string: "https://api.dhammatalkmobile.com/list?collection=\(talkCategory.collectionParam)&year=\(year)")!
        var request = URLRequest(url: url)
        request.addValue("iOS", forHTTPHeaderField: "client")
        request.addValue("1.5", forHTTPHeaderField: "client-version")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

        do {
            let (data, _) = try await urlSession.data(for: request)
            saveData(data, to: cacheFilename(talkCategory: talkCategory, year: year))
            let talkInfoList = try JSONDecoder().decode(CollectionResponse.self, from: data)
            return talkInfoList.body.map{ TalkData(serverTalkData: $0) }
        } catch {
            Logger.api.error("Error during API request: \(String(describing: error))")
            return await fetchCachedResults(for: talkCategory, year: year)
        }
    }
    
    private func fetchCachedResults(for talkCategory: DailyTalkCategory, year: Int) async -> [TalkData] {
        if let savedResponse = await checkForSavedResponse(talkCategory, year: year) {
            return savedResponse
        } else {
            let url = fileStorage.createURL(for: cacheFilename(talkCategory: talkCategory, year: year))
            do {
                return try await talkDataFromURL(url)
            } catch {
                Logger.fileStorage.error("Error during cache request: \(String(describing: error))")
                return []
            }
        }
    }

    private func saveData(_ data: Data, to filename: String) {
        do {
            // We save this for when we're in offline mode, so we can fallback and display the talks.  It's also
            // useful if we fail to retrieve the page for other reasons, it'll default back to this page.
            // Can't use URLCache, since our query changes due to cache busting strategy (see above).
            try fileStorage.saveData(data, withFilename: filename)
        } catch {
            Logger.fileStorage.error("Failed to save page cache '\(filename)': \(String(describing: error))")
        }
    }

    /// Since data from past years shouldn't really change, their data has been stored in app, in case it's needed.
    private func checkForSavedResponse(_ category: DailyTalkCategory, year: Int) async -> [TalkData]? {
        guard let jsonFileURL = Bundle.main.url(forResource: category.cachedFileNameForYear(year), withExtension: "json") else {
            return nil
        }

        do {
            return try await talkDataFromURL(jsonFileURL)
        } catch {
            return nil
        }
    }
    
    private func talkDataFromURL(_ url: URL) async throws -> [TalkData] {
        let (data, _) = try await urlSession.data(from: url)
        let talkInfoList = try JSONDecoder().decode(CollectionResponse.self, from: data)
        return talkInfoList.body.map{ TalkData(serverTalkData: $0) }
    }
    
    private func cacheFilename(talkCategory: DailyTalkCategory, year: Int) -> String {
        "\(talkCategory.collectionParam)_\(year).json"
    }
}
