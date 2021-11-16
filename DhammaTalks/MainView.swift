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
    
    let talkSeriesList: [TalkSeries]? = {
        if let path = Bundle.main.path(forResource: "TalkSeriesList", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let talkSeriesList = try JSONDecoder().decode([TalkSeries].self, from: data)
                return talkSeriesList
            } catch {
                return nil
            }
        }
        return nil
    }()

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .center, spacing: 20) {
                if let talkSeriesList = talkSeriesList {
                    ForEach(talkSeriesList) { talkSeries in
                        Text(talkSeries.title)
                            .bold()
                            .font(.system(size:30, weight:.bold, design:Font.Design.default))
                            .foregroundColor(Color("Colour 5"))
                        Text(talkSeries.description)
                            .font(.system(size:16, weight:.light))
                            .foregroundColor(Color("Colour 4"))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack{
                                ForEach(talkSeries.talks) { talk in
                                    VStack{
                                        Text(talk.title)
                                            .bold()
                                            .font(.system(size:20, weight:.bold))
                                            .foregroundColor(Color("Colour 4"))
                                        Image(talk.image)
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
