//
//  MainView.swift
//  DhammaTalks
//
//  Created by Brendan Miller on 2021-11-06.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import SwiftUI
import CoreMedia




struct MainView: View {
    
    let category: [CategoryTalks]? = {
        if let path = Bundle.main.path(forResource: "CategoryTalks", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let categoryTalks = try JSONDecoder().decode([CategoryTalks].self, from: data)
                return categoryTalks
            } catch {
                print(error)
                return nil
            }
        }
        return nil
    }()
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .center, spacing: 20) {
                if let category = category {
                    ForEach(category) {c in
                        Text(c.title)
                            .bold()
                            .font(.system(size:30, weight:.bold, design:Font.Design.default))
                            .foregroundColor(Color("Colour 5"))
                        ScrollView(.horizontal) {

                            HStack{
                                ForEach(c.talks) { t in
                                    VStack{
                                        Text(t.title)
                                            .bold()
                                            .font(.system(size:20, weight:.bold))
                                            .foregroundColor(Color("Colour 4"))
                                        Image(t.image)
                                            .resizable()
                                            .frame(width: 252, height:168, alignment:.center)
                                            .aspectRatio(contentMode:.fill)
                                            .cornerRadius(20)
                                            
                                    }
                                }

                            }

                        }

                    }
                }
            }
            
        }
        .frame(maxWidth: .infinity)
        .background(Color("Colour 1"))
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
