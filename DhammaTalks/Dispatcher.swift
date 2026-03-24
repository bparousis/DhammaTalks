//
//  Dispatcher.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2026-03-16.
//  Copyright © 2026 Bill Parousis. All rights reserved.
//

import Foundation

protocol Dispatcher {
    func asyncAfter(deadline: DispatchTime, execute work: @escaping () -> Void)
}

extension DispatchQueue: Dispatcher {
    
    func asyncAfter(deadline: DispatchTime, execute work: @escaping () -> Void) {
        self.asyncAfter(deadline: deadline, execute: DispatchWorkItem(block: work))
    }
}
