//
//  chatWindow.swift
//  OSai
//
//  Created by gill on 4/6/24.
//

import Foundation
import SwiftUI
struct PopupContentView: View {
    let inputText: String

    var body: some View {
        VStack {
            Text("Popup Window")
                .font(.title)
            Text("Input from menubar: \(inputText)")
        }
    }
}
