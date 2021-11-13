//
//  HTMLPageFetcher.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-08.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

enum TalkCategory {

    case short(year: Int)
    case evening(year: Int)
    case fiveStrengths
    case chants
    case guidedMeditations
    case refugeFromDeath
    case basics
    case eightfoldPath

    var talkURL: String {
        switch self {
        case let .short(year):
            return "\(HTMLPageFetcher.archivePath)/shorttalks/y\(year)"
        case let .evening(year):
            return "\(HTMLPageFetcher.archivePath)/y\(year)"
        case .fiveStrengths:
            return "\(HTMLPageFetcher.archivePath)/five_strengths"
        case .chants:
            return "\(HTMLPageFetcher.archivePath)/Chants"
        case .guidedMeditations:
            return "\(HTMLPageFetcher.archivePath)/guided_meditations"
        case .refugeFromDeath:
            return "\(HTMLPageFetcher.archivePath)/refuge_from_death"
        case .basics:
            return "\(HTMLPageFetcher.archivePath)/basics_collection"
        case .eightfoldPath:
            return "\(HTMLPageFetcher.archivePath)/TheEightfoldPath/"
        }
    }
    
    var isYearly: Bool {
        switch self {
        case .short(_), .evening(_):
            return true
        default:
            return false
        }
    }
}

class HTMLPageFetcher {
    
    static let archivePath = "https://www.dhammatalks.org/Archive"
    
    enum HTMLPageFetcherError: Error {
        case invalidURL
        case failedToRetrieve
    }

    func getHTMLForCategory(_ category: TalkCategory) async -> Result<HTMLData, HTMLPageFetcherError> {
        guard let talkURL = URL(string:category.talkURL) else {
            return .failure(.invalidURL)
        }

        do {
            let content = try String(contentsOf: talkURL)
            return .success(HTMLData(html: content, talkCategory: category))
        } catch {
            return .failure(.failedToRetrieve)
        }
    }
}
