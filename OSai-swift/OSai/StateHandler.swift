//
//  StateHandler.swift
//  OSai
//
//  Created by gill on 4/15/24.
//

import Foundation
import SwiftUI

class StateManager: ObservableObject {
    static let shared = StateManager()
    @Published var turnedOn = true
    @Published var currSystemImage = "eye.fill"
    @Published var textSleep = "OSai is awake"
    @Published var dataSendConfirmation = false;
    @Published var isPresented = false;
    private init() {} // Private initializer to ensure singleton usage
    
    func toggleState() {
        turnedOn.toggle()
    }
    
    func currSystemImageChange() {
        if currSystemImage == "eye.fill" {
            currSystemImage = "eye.slash"
        }
        else {
            currSystemImage = "eye.fill"
        }
    }
    
    func dataToggle() {
        dataSendConfirmation = !dataSendConfirmation;
    }
    
}
