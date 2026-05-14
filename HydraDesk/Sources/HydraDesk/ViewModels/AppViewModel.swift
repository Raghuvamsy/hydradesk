#if os(macOS)
import Foundation
import SwiftUI
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published var selectedModule: Module? = .dashboard
    @Published var launcherQuery = ""
    @Published var launcherVisible = false

    @Published var systemStats = SystemStatsSnapshot.empty
    @Published var launcherItems: [LauncherItem] = []
    @Published var clipboardItems: [ClipboardItem] = []
    @Published var notifications: [NotificationRecord] = []
    @Published var workspaceProfiles: [WorkspaceProfile] = []
    @Published var tasks: [TaskItem] = []

    @Published var wifiOn = false
    @Published var bluetoothOn = false
    @Published var vpnStatus = "Unknown"

    @Published var darkMode = false
    @Published var localFocusMode = false
    @Published var brightness = 0.8
    @Published var volume = 0.6

    @Published var wallpaperImages: [URL] = []

    private let statsService = SystemStatsService()
    private let launcherService = AppLauncherService()
    private let clipboardService = ClipboardService()
    private let notificationService = NotificationHubService()
    private let networkService = NetworkControlService()
    private let quickSettings = QuickSettingsService()
    private let wallpaperService = WallpaperService()
    private let workspaceService = WorkspaceService()
    private let tasksService = TasksService()

    private var menuBarController: MenuBarController?
    private var hotkeyService: HotkeyService?
    private var ticker: AnyCancellable?

    init() {
        hydrate()
        seedWorkspacePresets()

        menuBarController = MenuBarController(appViewModel: self)
        hotkeyService = HotkeyService { [weak self] in
            Task { @MainActor in
                self?.openLauncher()
            }
        }
        hotkeyService?.registerLauncherHotkey()

        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    var filteredLauncherItems: [LauncherItem] {
        guard !launcherQuery.isEmpty else { return Array(launcherItems.prefix(24)) }
        return Array(launcherItems.filter {
            $0.name.localizedCaseInsensitiveContains(launcherQuery)
            || $0.path.localizedCaseInsensitiveContains(launcherQuery)
        }.prefix(24))
    }

    func openLauncher() {
        launcherVisible = true
        selectedModule = .appLauncher
    }

    func closeLauncher() {
        launcherVisible = false
    }

    func launch(_ item: LauncherItem) {
        launcherService.launch(item: item)
        notificationService.add(title: "Launched", message: item.name)
        notifications = notificationService.history
    }

    func runPathSearchLaunch() {
        guard !launcherQuery.isEmpty else { return }
        launcherService.openPath(launcherQuery)
    }

    func toggleClipboardPinned(_ item: ClipboardItem) {
        clipboardService.setPinned(id: item.id, pinned: !item.isPinned)
        clipboardItems = clipboardService.items
    }

    func cleanupClipboard() {
        clipboardService.cleanupOlderThan(days: 7)
        clipboardItems = clipboardService.items
    }

    func setWallpaper(_ url: URL) {
        wallpaperService.setWallpaper(url)
        notificationService.add(title: "Wallpaper Updated", message: url.lastPathComponent)
        notifications = notificationService.history
    }

    func toggleWiFi(_ enabled: Bool) {
        networkService.setWiFi(enabled: enabled)
        refreshNetwork()
    }

    func toggleBluetooth(_ enabled: Bool) {
        networkService.setBluetooth(enabled: enabled)
        refreshNetwork()
    }

    func applyQuickSettings() {
        quickSettings.isDarkMode = darkMode
        quickSettings.localFocusMode = localFocusMode
        quickSettings.brightness = brightness
        quickSettings.volume = volume
    }

    func addTask(_ title: String) {
        tasksService.addTask(title)
        tasks = tasksService.tasks
    }

    func toggleTask(_ task: TaskItem) {
        tasksService.toggle(task)
        tasks = tasksService.tasks
    }

    func saveWorkspace(name: String) {
        workspaceService.saveCurrentWorkspace(name: name)
        workspaceProfiles = workspaceService.profiles
    }

    func restoreWorkspace(_ profile: WorkspaceProfile) {
        workspaceService.restore(profile)
        notificationService.add(title: "Workspace Restore", message: profile.name)
        notifications = notificationService.history
    }

    private func hydrate() {
        launcherItems = launcherService.discoverApps()
        clipboardItems = clipboardService.items
        notifications = notificationService.history
        workspaceProfiles = workspaceService.profiles
        tasks = tasksService.tasks

        darkMode = quickSettings.isDarkMode
        localFocusMode = quickSettings.localFocusMode
        brightness = quickSettings.brightness == 0 ? 0.8 : quickSettings.brightness
        volume = quickSettings.volume == 0 ? 0.6 : quickSettings.volume
        wallpaperImages = wallpaperService.discoverImages()

        refreshNetwork()
        tick()
    }

    private func refreshNetwork() {
        let state = networkService.currentState()
        wifiOn = state.wifiOn
        bluetoothOn = state.bluetoothOn
        vpnStatus = state.vpnStatus
    }

    private func seedWorkspacePresets() {
        workspaceService.installPresetIfMissing(name: "Coding", apps: ["/Applications/Xcode.app", "/Applications/iTerm.app"])
        workspaceService.installPresetIfMissing(name: "Study", apps: ["/Applications/Notes.app", "/Applications/Safari.app"])
        workspaceService.installPresetIfMissing(name: "Gaming", apps: ["/Applications/Steam.app"])
        workspaceProfiles = workspaceService.profiles
    }

    private func tick() {
        systemStats = statsService.snapshot()
        clipboardService.poll()
        clipboardItems = clipboardService.items
    }
}
#endif
