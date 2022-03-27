//
//  TalkUserInfo.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-26.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import CoreMedia

struct TalkUserInfo {
    var url: String
    var currentTime: CMTime
    var totalTime: CMTime
    var favoriteDetails: FavoriteDetails?
    var notes: String?
    
    var isFavorite: Bool {
        favoriteDetails != nil
    }

    var hasNotes: Bool {
        guard let notes = notes else {
            return false
        }
        return !notes.isEmpty
    }
}
