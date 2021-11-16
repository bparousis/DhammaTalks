//
//  HTMLPageFetcher.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-08.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

enum YearlyTalkCategory: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }

    case short
    case evening

    func talkURLForYear(_ year: Int) -> String {
        switch self {
        case .short:
            return "\(HTMLPageFetcher.archivePath)/shorttalks/y\(year)"
        case .evening:
            return "\(HTMLPageFetcher.archivePath)/y\(year)"
        }
    }
    
    var title: String {
        switch self {
        case .short:
            return "Short"
        case .evening:
            return "Evening"
        }
    }
    
    var startYear: Int {
        switch self {
        case .short:
            return 2010
        case .evening:
            return 2000
        }
    }
}

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

    func getYearlyHTMLForCategory(_ category: YearlyTalkCategory, year: Int) async -> Result<YearlyHTMLData, HTMLPageFetcherError> {
        guard let talkURL = URL(string:category.talkURLForYear(year)) else {
            return .failure(.invalidURL)
        }

        do {
            let (data, _) = try await urlSession.data(from: talkURL)
            guard let content = String(data: data, encoding: .utf8) else {
                return .failure(.failedToRetrieve)
            }
            return .success(YearlyHTMLData(html: content, talkCategory: category, year: year))
        } catch {
            return .failure(.failedToRetrieve)
        }
    }
}
