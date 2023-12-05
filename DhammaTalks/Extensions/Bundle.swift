//
//  Bundle.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2023-11-12.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import Foundation

extension Bundle {
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}
