//
//  ContentView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-11.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    let categoryTalks: [CategoryTalks]? = {
        if let path = Bundle.main.path(forResource: "CategoryTalks", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let categoryTalks = try JSONDecoder().decode([CategoryTalks].self, from: data)
                return categoryTalks
            } catch {
                return nil
            }
        }
        return nil
    }()
    
    var body: some View {
        return NavigationView {
            MainView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
