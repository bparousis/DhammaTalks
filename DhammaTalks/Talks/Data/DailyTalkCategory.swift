//
//  DailyTalkCategory.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-19.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

enum DailyTalkCategory: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }

    case short
    case evening

    func directoryForYear(_ year: Int) -> String {
        switch self {
        case .short:
            return "shorttalks/y\(year)"
        case .evening:
            return "y\(year)"
        }
    }
    
    func cachedFileNameForYear(_ year: Int) -> String {
        switch self {
        case .short:
            return "short_y\(year)"
        case .evening:
            return "y\(year)"
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

    var collectionParam: String {
        switch self {
        case .evening:
            return "evening"
        case .short:
            return "morning"
        }
    }
}
