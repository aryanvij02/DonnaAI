import SwiftUI

var LLMresult = "Your Results will show up here!"

func obtainResult(context: String) {
    LLMresult = context
}

struct PopoverContentView: View {
    @State private var textLLMResult: String = LLMresult

    var body: some View {
        VStack {
            TextEditor(text: $textLLMResult) // Use TextEditor for selectable and copyable text
//                .frame(minWidth: 100, minHeight: 100) // Set a minimum size
                .padding()
                .border(Color.gray, width: 1) // Set border properties
                .cornerRadius(5) // Rounded corners
        }
        .frame(width: 250, height: 200) // Outer VStack frame settings
        .padding()
    }
}
