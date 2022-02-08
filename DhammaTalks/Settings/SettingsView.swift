//
//  SettingsView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-02-07.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftUI
import MessageUI

struct SettingsView: View {
    
    @State private var showMailView: Bool = false
    @State var result: Result<MFMailComposeResult, Error>? = nil
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(appVersion)
                }
            }
            
            Section {
                Link("Dhamma Talks Site", destination: URL(string: "https://www.dhammatalks.org")!)
                if MFMailComposeViewController.canSendMail() {
                    Button {
                        showMailView = true
                    } label: {
                        Text("Questions & Feedback")
                    }
                }
            }
        }
        .sheet(isPresented: $showMailView) {
            MailView(isShowing: $showMailView, result: self.$result)
        }
    }
}
