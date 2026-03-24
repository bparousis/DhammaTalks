//
//  View.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-03-26.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import SwiftUI

extension View {

    var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
