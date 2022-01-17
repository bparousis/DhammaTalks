//
//  DependencyContainer.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-01-16.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation

struct DependencyContainer {
    let defaults: UserDefaults
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    static let main = DependencyContainer(defaults: .standard)
}

var Current: DependencyContainer = .main
