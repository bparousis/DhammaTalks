//
//  CircularProgressBar.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-12-07.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftUI

struct CircularProgressBar: View {
    
    @Binding var progress: CGFloat?
    var lineWidth: CGFloat = 2.0
    var stopAction: () -> Void

    var body: some View {
        GeometryReader { geo in
            Button(action: { stopAction() }) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: lineWidth)
                        .opacity(0.3)
                        .foregroundColor(Color(.systemOrange))
                    if let progress = progress {
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                            .foregroundColor(Color(.systemBlue))
                            .rotationEffect(Angle(degrees: 270.0))
                        
                        let size = geo.size.width/3.0
                        Rectangle()
                            .frame(width: size, height: size, alignment: .center)
                            .foregroundColor(Color(.systemBlue))
                    }
                }
            }
        }
    }
}
