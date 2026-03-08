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
    @State private var showMailAlert: Bool = false
    @State var result: Result<MFMailComposeResult, Error>? = nil
    
    // The value will be stored in UserDefaults with the key "isDarkModeEnabled"
    @AppStorage(AppSettings.autoplayKey) private var autoplay: Bool = true
    @AppStorage(AppSettings.useCellularDataKey) private var useCellularData: Bool = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.appVersion)
                }
            }
            
            Section("Autoplay") {
                Toggle("Automatically Play Next Talk", isOn: $autoplay)
                Toggle("Allow on Cellular DSata", isOn: $useCellularData)
            }
            
            Section {
                Link("Dhamma Talks Site", destination: URL(string: "https://www.dhammatalks.org")!)
                Link("Donate to Dhamma Talks", destination: URL(string: "https://www.dhammatalks.org/donations.html")!)
                Button {
                    if MFMailComposeViewController.canSendMail() {
                        showMailView = true
                    } else {
                        showMailAlert = true
                    }
                } label: {
                    Text("Questions & Feedback")
                }
            }
        }
        .sheet(isPresented: $showMailView) {
            MailView(isShowing: $showMailView, result: self.$result)
        }
        .alert("Device is not setup to send mail", isPresented: $showMailAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}
