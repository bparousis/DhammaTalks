//
//  AppSettings.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-01-16.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation

struct AppSettings {

    private static let talkGroupSelectionKey = "talkGroupSelection"
    private static let selectedTalkYearKey = "selectedTalkYear"
    private static let selectedTalkCategoryKey = "selectedTalkCategory"
    static let autoplayKey = "autoplay"
    static let useCellularDataKey = "useCellularData"
    
    static func registerDefaults() {
        Current.defaults.register(defaults: [
            Self.autoplayKey: true,
            Self.useCellularDataKey: false
        ])
    }

    static var talkGroupSelection: String? {
        set {
            Current.defaults.set(newValue, forKey: Self.talkGroupSelectionKey)
        }

        get {
            Current.defaults.string(forKey: Self.talkGroupSelectionKey)
        }
    }

    static var selectedTalkYear: Int? {
        set {
            Current.defaults.set(newValue, forKey: Self.selectedTalkYearKey)
        }

        get {
            let storedValue = Current.defaults.integer(forKey: Self.selectedTalkYearKey)
            return storedValue == 0 ? nil : storedValue
        }
    }

    static var selectedTalkCategory: DailyTalkCategory? {
        set {
            Current.defaults.set(newValue?.rawValue, forKey: Self.selectedTalkCategoryKey)
        }

        get {
            guard let storedValue = Current.defaults.string(forKey: Self.selectedTalkCategoryKey) else {
                return nil
            }
            return DailyTalkCategory(rawValue: storedValue)
        }
    }
    
    static var autoplay: Bool {
        set {
            Current.defaults.set(newValue, forKey: Self.autoplayKey)
        }

        get {
            Current.defaults.bool(forKey: Self.autoplayKey)
        }
    }
}
