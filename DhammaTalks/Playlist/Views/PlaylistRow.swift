//
//  PlaylistRow.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2023-07-15.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import SwiftUI

struct PlaylistRow: View {
    
    @ObservedObject var viewModel: PlaylistRowViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .font(.headline)
                Text(viewModel.descriptionText)
                    .font(.subheadline)
            }
        }
    }
}
