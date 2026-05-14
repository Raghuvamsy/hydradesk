import Foundation

enum Module: String, CaseIterable, Identifiable {
    case dashboard
    case systemStats
    case appLauncher
    case clipboard
    case wallpaper
    case network
    case notifications
    case workspace
    case quickSettings
    case tasks

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .systemStats: "System Stats"
        case .appLauncher: "App Launcher"
        case .clipboard: "Clipboard"
        case .wallpaper: "Wallpaper"
        case .network: "Network"
        case .notifications: "Notification Hub"
        case .workspace: "Workspace"
        case .quickSettings: "Quick Settings"
        case .tasks: "Tasks"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "rectangle.grid.2x2"
        case .systemStats: "gauge.with.dots.needle.50percent"
        case .appLauncher: "magnifyingglass"
        case .clipboard: "clipboard"
        case .wallpaper: "photo"
        case .network: "network"
        case .notifications: "bell.badge"
        case .workspace: "rectangle.3.group"
        case .quickSettings: "slider.horizontal.3"
        case .tasks: "checklist"
        }
    }
}
