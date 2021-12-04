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
    var starred: Bool
    var downloadPath: String?
}
