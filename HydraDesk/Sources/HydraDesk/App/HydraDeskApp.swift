#if os(macOS)
import SwiftUI

@main
struct HydraDeskApp: App {
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup("HydraDesk") {
            RootView(viewModel: appViewModel)
                .frame(minWidth: 1080, minHeight: 720)
        }
        .commands {
            CommandMenu("HydraDesk") {
                Button("Open Launcher") {
                    appViewModel.openLauncher()
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])
            }
        }
    }
}
#endif
