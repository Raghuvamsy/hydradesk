#if os(macOS)
import SwiftUI

struct RootView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        NavigationSplitView {
            List(Module.allCases, selection: $viewModel.selectedModule) { module in
                Label(module.title, systemImage: module.systemImage)
                    .tag(module as Module?)
            }
            .navigationTitle("HydraDesk")
        } detail: {
            ZStack {
                content
                if viewModel.launcherVisible {
                    LauncherOverlayView(viewModel: viewModel)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.spring(duration: 0.25), value: viewModel.launcherVisible)
            .padding()
            .background(.regularMaterial)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.selectedModule ?? .dashboard {
        case .dashboard: DashboardView(viewModel: viewModel)
        case .systemStats: SystemStatsView(viewModel: viewModel)
        case .appLauncher: AppLauncherView(viewModel: viewModel)
        case .clipboard: ClipboardView(viewModel: viewModel)
        case .wallpaper: WallpaperView(viewModel: viewModel)
        case .network: NetworkControlsView(viewModel: viewModel)
        case .notifications: NotificationHubView(viewModel: viewModel)
        case .workspace: WorkspaceView(viewModel: viewModel)
        case .quickSettings: QuickSettingsView(viewModel: viewModel)
        case .tasks: TasksView(viewModel: viewModel)
        }
    }
}
#endif
