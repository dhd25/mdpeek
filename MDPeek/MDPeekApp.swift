import SwiftUI

@main
struct MDPeekApp: App {
    var body: some Scene {
        WindowGroup("MDPeek") {
            ContentView()
                .frame(minWidth: 480, maxWidth: 480, minHeight: 460, maxHeight: 460)
        }
        .windowResizability(.contentSize)
    }
}
