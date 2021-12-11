//
//  TalkUserInfoMO.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-12-09.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import CoreMedia

extension TalkUserInfoMO {
    func toDomainModel() -> TalkUserInfo {
        let currentCMTime = CMTime(value: currentTimeValue, timescale: currentTimeScale)
        let totalCMTime = CMTime(value: totalTimeValue, timescale: totalTimeScale)
        
        return TalkUserInfo(url: url ?? "", currentTime: currentCMTime, totalTime: totalCMTime, favorite: favorite)
    }
}
