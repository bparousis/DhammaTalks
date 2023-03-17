//
//  Logger.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-12-06.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import os.log

extension Logger {
    static let talkUserInfo = Logger(subsystem: "com.bparousis.DhammaTalks", category: "TalkUserInfo")
    static let fileStorage = Logger(subsystem: "com.bparousis.DhammaTalks", category: "FileStorage")
    static let audio = Logger(subsystem: "com.bparousis.DhammaTalks", category: "Audio")
    static let playlist = Logger(subsystem: "com.bparousis.DhammaTalks", category: "Playlist")
}
