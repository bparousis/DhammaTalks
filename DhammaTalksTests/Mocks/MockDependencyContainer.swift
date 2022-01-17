//
//  MockDependencyContainer.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2022-01-16.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation
@testable import DhammaTalks

extension DependencyContainer {
    static var mock = DependencyContainer(defaults: .mock)
}

extension UserDefaults {
    static var mock: UserDefaults = {
        let userDefaults = UserDefaults(suiteName: "DhammaTalksTests")!
        userDefaults.removePersistentDomain(forName: "DhammaTalksTests")
        return userDefaults
    }()
}
