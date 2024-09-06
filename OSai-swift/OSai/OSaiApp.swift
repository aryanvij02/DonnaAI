//
//  OSaiApp.swift
//  OSai
//
//  Created by gill on 4/2/24.
//

import SwiftUI

@main
struct OSaiApp: App {
    @State private var x = ScreenShotHandler()
    @State private var currSystemImage = "eye.fill"

    var body: some Scene {
        MenuBarExtra("UtilityApp", systemImage: currSystemImage) {
            HStack {
                Button("", systemImage: "power") {
                    toggleState()
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.all, 10)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .topLeading)
            ZStack {
                AppMenu()
            }
        }
        .menuBarExtraStyle(.window)
    }

    private func toggleState() {
        StateManager.shared.turnedOn = !StateManager.shared.turnedOn
        if StateManager.shared.turnedOn  {
            currSystemImage = "eye.fill"
        } else {
            currSystemImage = "eye.slash"
        }
    }

    init() {
        x.textFileClear()
        x.startScreenshotTask()
    }
}
