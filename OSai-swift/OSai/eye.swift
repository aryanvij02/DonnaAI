import SwiftUI
import AppKit
import Vision
import Cocoa
import UserNotifications

struct AppMenu: View {
    @State private var inputString = ""
    @State private var submittedString = ""
    @State private var isPresented = false
    @State private var scale: CGFloat = 0.1
    @State private var color: Color = .yellow
    @State private var result = ""
    @State private var interval = 0
    @State private var screenshotTimer: Timer?
    @State private var loading = false
    @State private var showResult = false
    @State private var toggleButton = false
    @ObservedObject var stateManager = StateManager.shared
    @State private var textSleep = "OSai is awake"
    @State private var isAnimating = false
    @State private var actionConfirmed = false
    @State private var isConfirmationPresented = false
    @State private var gradColors = Gradient(colors: [Color.white.opacity(1), Color.blue.opacity(0.5), Color.yellow.opacity(0.5)])
    let gradientColors = Gradient(colors: [.green, .gray, .green])
        let gradientStart = UnitPoint(x: 0, y: 0.5)
        let gradientEnd = UnitPoint(x: 1, y: 0.5)

    private var ssHandler = ScreenShotHandler()
    private var llmHandler = LLMHandler()

    @State private var isPopoverPresented = false
    @State private var isWindowOpen = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: gradColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.7)
                .blur(radius: 15.0)
                .edgesIgnoringSafeArea(.all)

            Capsule()
                .frame(width: 200, height: 200)
                .scaleEffect(scale)
                .foregroundColor(color)
                .opacity(loading ? 0.65 : 0.10)
                .onAppear {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("Authorization granted")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    startAnimation()
                }
                .onChange(of: StateManager.shared.turnedOn) { newValue in
                    StateManager.shared.textSleep = newValue ? "OSai is awake" : "OSai is asleep"
                    sendNotification(title: "Donna is sleeping.", subtitle: "YOOO", body: "AYYYY")
                    updateGradientColors()
                    startAnimation()
                }

            VStack {
                
                Text(StateManager.shared.textSleep)
                HStack {
                               Text("Donna")
                                   .italic()
                                   .fontWeight(.bold)
                                   .foregroundStyle(Color.white)
                                   .font(.system(size: 40, weight: .semibold, design: .rounded))
                                   .shadow(color: .black, radius: 2)
                                   
                               Text("Pro").italic().bold().font(.title3)
                                   .overlay(
                                    LinearGradient(colors: [.pink, .purple,.pink], startPoint: .leading, endPoint: .trailing)
                                           .padding(0.0)
                                           .mask(Text("Pro").italic().bold().font(.title3))
                                   ).shadow(color: .white, radius: 2)
                           }.padding(10)
                
                VStack {
                                if StateManager.shared.turnedOn {
                                    TextField("Press return to submit", text: $inputString)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white).opacity(0.3)
                                                .shadow(color: .gray.opacity(0.5), radius: 2, x: 2, y: 2)
                                                .shadow(color: .white.opacity(0.7), radius: 2, x: -1, y: -1)
                                        )
                                        .onSubmit {
                                            isConfirmationPresented = true
                                        }
                                }

                                if isConfirmationPresented {
                                    confirmationView
                                }
                }

                HStack{
                    Button("Copy") {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(result, forType: .string)
                    }

                    Button("Clear Data") {
                        withAnimation {
                            submittedString = ""
                            inputString = ""
                            result = ""
                            ssHandler.textFileClear()
                            showResult = false
                            loading = false
                        }
                        sendNotification(title: "Data Cleared", subtitle: "All inputs have been reset", body: "You can start anew now.")
                    }
                }
                
                Divider().padding(10)
                
//                if isConfirmationPresented {
//                    VStack {
//                        Text("CONFIRMATION").padding(2).font(.headline).fontWeight(.bold)
//                        Button("Always Allow", action: {
//                            StateManager.shared.dataSendConfirmation = true
//                            isConfirmationPresented = !isConfirmationPresented
//                        })
//                        Button("Cancel", action: {
//                            StateManager.shared.dataSendConfirmation = false
//                            isConfirmationPresented = !isConfirmationPresented
//                        })
//                        Divider().padding(10)
//
//                        .popover(isPresented: $isPopoverPresented, arrowEdge: .bottom) {
//                            PopoverContentView()
//                        }.padding(10)
//                    }
//                    .transition(.opacity.combined(with: .slide))
//                }
                
                
                if showResult {
                    VStack {
                        Text("RESULT").padding(2).font(.headline).fontWeight(.bold)
                        Text(result).font(.caption2)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .minimumScaleFactor(0.5)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)

                        Divider().padding(10)

                        Button("Expand") {
                            isPopoverPresented = true  // Toggle the state to show the popover
                        }
                        .popover(isPresented: $isPopoverPresented, arrowEdge: .bottom) {
                            PopoverContentView()
                        }.padding(10)
                    }
                    .transition(.opacity.combined(with: .slide))
                }
            }
            .animation(.easeInOut, value: showResult)
        }
        .padding()

    }

    private func startAnimation() {
        let baseAnimation = Animation.easeInOut(duration: 0.95)
        let repeated = stateManager.turnedOn ? baseAnimation.repeatForever(autoreverses: true) : baseAnimation
        withAnimation(repeated) {
            scale = stateManager.turnedOn ? 1.0 : 0
            color = stateManager.turnedOn ? Color.blue : Color.black
        }
    }

    private func updateGradientColors() {
        if !StateManager.shared.turnedOn {
            gradColors = Gradient(colors: [Color.black.opacity(0.5), Color.white.opacity(1)])
        } else {
            gradColors = Gradient(colors: [Color.white.opacity(1), Color.blue.opacity(0.5), Color.yellow.opacity(0.5)])
        }
    }

    private func sendNotification(title: String, subtitle: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    var confirmationView: some View {
            VStack {
                Text("CONFIRMATION").padding(2).font(.headline).fontWeight(.bold)
                Text("Your data is being sent to OpenAI, you may check contents to verify comfortability.").padding(2).font(.caption).fontWeight(.thin)
                Button("Allow", action: {
                    StateManager.shared.dataSendConfirmation = true
                    isConfirmationPresented = false
                    submitData()
                })
                Button("Cancel", action: {
                    StateManager.shared.dataSendConfirmation = false
                    isConfirmationPresented = false
                })
                Divider().padding(10)
            }
            .transition(.opacity.combined(with: .slide))
        }

        private func submitData() {
            if StateManager.shared.dataSendConfirmation {
                loading = true
                showResult = true
                result = "loading..."
                submittedString = inputString.lowercased()
                inputString = ""
                llmHandler.getGemini(context: ssHandler.getTextContent(), body: submittedString, completion: { geminiResult in
                    result = geminiResult
                    DispatchQueue.main.async {
                        loading = false
                        ssHandler.textFileClear()
                    }
                })
            }
        }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppMenu()
    }
}
