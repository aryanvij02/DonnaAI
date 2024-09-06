import SwiftUI
struct ConfirmationPopupView: View {
    var onConfirm: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack {
            Text("Confirmation")
                .font(.title)
                .padding()
            
            Text("Are you sure you want to submit the query?")
                .padding()
            
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                
                Button("Confirm") {
                    onConfirm()
                }
                .padding()
            }
            .padding()
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}
