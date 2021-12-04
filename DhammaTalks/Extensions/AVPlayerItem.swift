//
//  AVPlayerItem.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-30.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import AVFoundation

extension AVPlayerItem: Identifiable {
    public var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}
