//
//  HTMLPageFetcher.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-08.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation


class HTMLPageFetcher {
    
    static let archivePath = "https://www.dhammatalks.org/Archive"
    
    enum TalkCategory {

        case short(year: Int)
        case evening(year: Int)
        case fiveStrengths
        case chants
        case guidedMeditations
        case refugeFromDeath
        case basics
        case eightfoldPath

        var talkURL: URL? {
            switch self {
            case let .short(year):
                return URL(string: "\(HTMLPageFetcher.archivePath)/shorttalks/y\(year)")
            case let .evening(year):
                return URL(string: "\(HTMLPageFetcher.archivePath)/y\(year)")
            case .fiveStrengths:
                return URL(string: "\(HTMLPageFetcher.archivePath)/five_strengths")
            case .chants:
                return URL(string: "\(HTMLPageFetcher.archivePath)/Chants")
            case .guidedMeditations:
                return URL(string: "\(HTMLPageFetcher.archivePath)/guided_meditations")
            case .refugeFromDeath:
                return URL(string: "\(HTMLPageFetcher.archivePath)/refuge_from_death")
            case .basics:
                return URL(string: "\(HTMLPageFetcher.archivePath)/basics_collection")
            case .eightfoldPath:
                return URL(string: "\(HTMLPageFetcher.archivePath)/TheEightfoldPath/")
            }
        }
    }

    func getHTMLForCategory(_ category: TalkCategory) -> String? {
        guard let talkURL = category.talkURL else {
            return nil
        }

        do {
            return try String(contentsOf: talkURL)
        } catch {
            return nil
        }
    }
}
