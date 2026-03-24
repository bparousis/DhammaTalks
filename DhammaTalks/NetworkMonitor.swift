//
//  NetworkMonitor.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2026-03-08.
//  Copyright © 2026 Bill Parousis. All rights reserved.
//

import Combine
import Network

protocol NetworkMonitoring {
    var isCellular: Bool { get }
    var isWifi: Bool { get }
}

class NetworkMonitor: ObservableObject, NetworkMonitoring {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isCellular = false
    @Published var isWifi = false
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isCellular = path.usesInterfaceType(.cellular)
                self.isWifi = path.usesInterfaceType(.wifi)
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
