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
    private static let playbackRateKey = "playbackRate"
    static let autoplayKey = "autoplay"
    static let useCellularDataKey = "useCellularData"
    
    static func registerDefaults() {
        Current.defaults.register(defaults: [
            Self.autoplayKey: true,
            Self.useCellularDataKey: false,
            Self.playbackRateKey: 1.0
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
    
    static var useCellularData: Bool {
        set {
            Current.defaults.set(newValue, forKey: Self.useCellularDataKey)
        }

        get {
            Current.defaults.bool(forKey: Self.useCellularDataKey)
        }
    }

    static var playbackRate: PlaybackSpeed {
        set {
            let value = max(PlaybackSpeed.slowest.rawValue, min(newValue.rawValue, PlaybackSpeed.fastest.rawValue))
            Current.defaults.set(value, forKey: Self.playbackRateKey)
        }

        get {
            return PlaybackSpeed(rawValue: Current.defaults.float(forKey: Self.playbackRateKey)) ?? PlaybackSpeed.normal
        }
    }
}
