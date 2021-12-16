import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Button { 
                print("button print")
            } label: { 
                Text("Button Text")
            }
            
            Text("Hello, world!")
        }
    }
}
