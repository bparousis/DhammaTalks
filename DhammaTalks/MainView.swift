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
        ScrollView(.vertical){
            VStack(alignment: .center, spacing: 20){
                if let category = category {
                    ForEach(category){c in
                        Text(c.title)
                            .bold()
                            .font(.system(size:30, weight:.bold, design:Font.Design.default))
                        ScrollView(.horizontal){

                            HStack{
                                ForEach(c.talks){ t in
                                    VStack{
                                        Text(t.title)
                                            .bold()
                                            .font(.system(size:20, weight:.bold))
                                        Image("Talk1")
                                    }
                                }

                            }

                        }

                    }
                }
            }
        }
    }
}


struct TalkView: Identifiable{
    let id = UUID()
    let name: String
    let colour: Color
    let title: String
    let imageName: String

    let category: Category
    
}

enum Category{
    case beginner
    case morning
    case recommended
}
            
let items = [
    TalkView   (name: "",
                colour: Color(.blue),
                title: "Recommendations",
                imageName: "",
                category: Category.recommended
               )
]

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
