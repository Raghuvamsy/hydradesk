#if os(macOS)
import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 12)], spacing: 12) {
                FrostedCard("CPU") { Text("\(viewModel.systemStats.cpuUsage, specifier: "%.1f")%") }
                FrostedCard("Memory") { Text("\(viewModel.systemStats.memoryUsedGB, specifier: "%.1f") / \(viewModel.systemStats.memoryTotalGB, specifier: "%.1f") GB") }
                FrostedCard("Disk") { Text("\(viewModel.systemStats.diskUsedGB, specifier: "%.1f") / \(viewModel.systemStats.diskTotalGB, specifier: "%.1f") GB") }
                FrostedCard("Battery") { Text("\(viewModel.systemStats.batteryPercent ?? 0, specifier: "%.0f")%") }
                FrostedCard("Network") { Text("↓ \(viewModel.systemStats.networkDownKBps, specifier: "%.0f") KB/s   ↑ \(viewModel.systemStats.networkUpKBps, specifier: "%.0f") KB/s") }
                FrostedCard("Tasks") {
                    let done = viewModel.tasks.filter(\.done).count
                    Text("\(done)/\(viewModel.tasks.count) complete")
                }
            }
        }
    }
}

struct SystemStatsView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("System Stats").font(.largeTitle.bold())
            FrostedCard("Live") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CPU: \(viewModel.systemStats.cpuUsage, specifier: "%.1f")%")
                    Text("Memory: \(viewModel.systemStats.memoryUsedGB, specifier: "%.1f") / \(viewModel.systemStats.memoryTotalGB, specifier: "%.1f") GB")
                    Text("Disk: \(viewModel.systemStats.diskUsedGB, specifier: "%.1f") / \(viewModel.systemStats.diskTotalGB, specifier: "%.1f") GB")
                    Text("Battery: \(viewModel.systemStats.batteryPercent ?? 0, specifier: "%.0f")%")
                    Text("Network: ↓\(viewModel.systemStats.networkDownKBps, specifier: "%.0f") ↑\(viewModel.systemStats.networkUpKBps, specifier: "%.0f") KB/s")
                }
            }
            Spacer()
        }
    }
}

struct AppLauncherView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                TextField("Search apps or enter path", text: $viewModel.launcherQuery)
                    .textFieldStyle(.roundedBorder)
                Button("Open") { viewModel.runPathSearchLaunch() }
            }

            List(viewModel.filteredLauncherItems) { item in
                Button {
                    viewModel.launch(item)
                } label: {
                    VStack(alignment: .leading) {
                        Text(item.name)
                        Text(item.path)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct LauncherOverlayView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack {
            AppLauncherView(viewModel: viewModel)
                .frame(width: 640, height: 420)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    Button {
                        viewModel.closeLauncher()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.2))
    }
}

struct ClipboardView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var query = ""

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                TextField("Search clipboard", text: $query)
                    .textFieldStyle(.roundedBorder)
                Button("Cleanup") { viewModel.cleanupClipboard() }
            }

            List(filteredItems) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.text ?? "<Image>").lineLimit(2)
                        Text(item.createdAt, style: .time).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(item.isPinned ? "Unpin" : "Pin") {
                        viewModel.toggleClipboardPinned(item)
                    }
                }
            }
        }
    }

    private var filteredItems: [ClipboardItem] {
        guard !query.isEmpty else { return viewModel.clipboardItems }
        return viewModel.clipboardItems.filter { ($0.text ?? "").localizedCaseInsensitiveContains(query) }
    }
}

struct WallpaperView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        List(viewModel.wallpaperImages, id: \.self) { imageURL in
            HStack {
                Text(imageURL.lastPathComponent)
                Spacer()
                Button("Set") { viewModel.setWallpaper(imageURL) }
            }
        }
    }
}

struct NetworkControlsView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Wi‑Fi", isOn: Binding(get: { viewModel.wifiOn }, set: { viewModel.toggleWiFi($0) }))
            Toggle("Bluetooth", isOn: Binding(get: { viewModel.bluetoothOn }, set: { viewModel.toggleBluetooth($0) }))
            Text("VPN: \(viewModel.vpnStatus)")
            Text("Network speed: ↓\(viewModel.systemStats.networkDownKBps, specifier: "%.0f") ↑\(viewModel.systemStats.networkUpKBps, specifier: "%.0f") KB/s")
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct NotificationHubView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        List(viewModel.notifications) { note in
            VStack(alignment: .leading) {
                Text(note.title).font(.headline)
                Text(note.message)
                Text(note.createdAt, style: .time).font(.caption).foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        }
    }
}

struct WorkspaceView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var workspaceName = ""

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                TextField("Workspace name", text: $workspaceName)
                Button("Save Current") {
                    viewModel.saveWorkspace(name: workspaceName)
                    workspaceName = ""
                }
            }

            List(viewModel.workspaceProfiles) { profile in
                HStack {
                    VStack(alignment: .leading) {
                        Text(profile.name)
                        Text("\(profile.appPaths.count) apps").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Restore") { viewModel.restoreWorkspace(profile) }
                }
            }
        }
    }
}

struct QuickSettingsView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Dark Mode", isOn: $viewModel.darkMode)
            Toggle("Focus Mode (local)", isOn: $viewModel.localFocusMode)
            Text("Brightness")
            Slider(value: $viewModel.brightness, in: 0 ... 1)
            Text("Volume")
            Slider(value: $viewModel.volume, in: 0 ... 1)
            Button("Apply") { viewModel.applyQuickSettings() }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct TasksView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var taskTitle = ""
    @State private var timerSeconds = 25 * 60
    @State private var timerRunning = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField("New todo", text: $taskTitle)
                Button("Add") {
                    viewModel.addTask(taskTitle)
                    taskTitle = ""
                }
            }

            HStack {
                Text("Focus timer: \(timerSeconds / 60)m \(timerSeconds % 60)s")
                Button(timerRunning ? "Pause" : "Start") { timerRunning.toggle() }
                Button("Reset") {
                    timerSeconds = 25 * 60
                    timerRunning = false
                }
            }

            List(viewModel.tasks) { task in
                Button {
                    viewModel.toggleTask(task)
                } label: {
                    HStack {
                        Image(systemName: task.done ? "checkmark.circle.fill" : "circle")
                        Text(task.title)
                    }
                }
                .buttonStyle(.plain)
            }

            let completed = viewModel.tasks.filter(\.done).count
            Text("Completion: \(ProductivityMetrics.completionRate(completed: completed, total: viewModel.tasks.count) * 100, specifier: "%.0f")%")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard timerRunning, timerSeconds > 0 else { return }
            timerSeconds -= 1
        }
    }
}

struct MenuBarPopoverView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HydraDesk").font(.headline)
            Text("CPU: \(viewModel.systemStats.cpuUsage, specifier: "%.1f")%")
            Text("RAM: \(viewModel.systemStats.memoryUsedGB, specifier: "%.1f")/\(viewModel.systemStats.memoryTotalGB, specifier: "%.1f") GB")
            Text("Net: ↓\(viewModel.systemStats.networkDownKBps, specifier: "%.0f") ↑\(viewModel.systemStats.networkUpKBps, specifier: "%.0f") KB/s")
            Divider()
            Button("Open Launcher") { viewModel.openLauncher() }
            Button("Open Tasks") { viewModel.selectedModule = .tasks }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
#endif
