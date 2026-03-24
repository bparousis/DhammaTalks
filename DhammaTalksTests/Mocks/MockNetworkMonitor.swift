//
//  MockNetworkMonitor.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2026-03-16.
//  Copyright © 2026 Bill Parousis. All rights reserved.
//

@testable import DhammaTalks

struct MockNetworkMonitor: NetworkMonitoring {
    var isCellular: Bool
    var isWifi: Bool
    
    init(isCellular: Bool = false, isWifi: Bool = true) {
        self.isCellular = isCellular
        self.isWifi = isWifi
    }
}
