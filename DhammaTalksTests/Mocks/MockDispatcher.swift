//
//  MockDispatcher.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2026-03-16.
//  Copyright © 2026 Bill Parousis. All rights reserved.
//

import Foundation

@testable import DhammaTalks

class MockDispatcher: Dispatcher {
    func asyncAfter(deadline: DispatchTime, execute work: @escaping () -> Void) {
        // Run the work immediately, ignoring the actual delay
        work()
    }
}
