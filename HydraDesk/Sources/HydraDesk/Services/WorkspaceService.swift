#if os(macOS)
import Foundation
import AppKit

@MainActor
final class WorkspaceService {
    private(set) var profiles: [WorkspaceProfile] = Persistence.load([WorkspaceProfile].self, from: "workspaces.json", fallback: [])

    func saveCurrentWorkspace(name: String) {
        let profileName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Workspace \(Date().formatted())" : name
        let appPaths = NSWorkspace.shared.runningApplications.compactMap { $0.bundleURL?.path }
        profiles.insert(.init(id: UUID(), name: profileName, appPaths: appPaths, createdAt: Date()), at: 0)
        Persistence.save(profiles, to: "workspaces.json")
    }

    func restore(_ profile: WorkspaceProfile) {
        for path in profile.appPaths {
            NSWorkspace.shared.openFile(path)
        }
    }

    func installPresetIfMissing(name: String, apps: [String]) {
        guard !profiles.contains(where: { $0.name == name }) else { return }
        profiles.append(.init(id: UUID(), name: name, appPaths: apps, createdAt: Date()))
        Persistence.save(profiles, to: "workspaces.json")
    }
}
#endif
