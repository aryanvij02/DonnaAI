////
////  ConfirmationPopup.swift
////  OSai
////
////  Created by gill on 4/17/24.
////
//
//import Foundation
//import SwiftUI
//
//
//
//
//import Foundation
//import SwiftUI
//
//struct NewPopoverContentView: View {
//    @State private var textLLMResult: String = LLMresult
//    @Environment(\.presentationMode) var presentationMode
//    @State private var isPresented: Bool = true
//    @Binding var sendCall: Bool
//    @Binding var allowDataSend: Bool
//
//    var body: some View {
//        if isPresented {
//            VStack {
//                Text("Please Select One.")
//                
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                    StateManager.shared.dataSendConfirmation = true
//                    allowDataSend = true
//                    sendCall = true
//                    isPresented = false
//                }) {
//                    Text("Always allow.")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding()
//                
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                    allowDataSend = true
//                    sendCall = true
//                    isPresented = false
//                }) {
//                    Text("Allow Once")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding()
//                
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                    StateManager.shared.dataSendConfirmation = false
//                    allowDataSend = false
//                    sendCall = false
//                    isPresented = false
//                }) {
//                    Text("Cancel")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding()
//            }
//            .frame(width: 250, height: 250)
//            .padding()
//            .onChange(of: StateManager.shared.isPresented) { newValue in
//                isPresented = newValue
//            }
//        } else {
//            Text("Press esc to remove.")
//        }
//    }
//}
