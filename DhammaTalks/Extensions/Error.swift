//
//  Error.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-12-11.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

extension Error {
    var isCancelError: Bool {
        self is CancellationError || (self as NSError).code == URLError.cancelled.rawValue
    }
}
