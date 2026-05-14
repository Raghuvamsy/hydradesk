#if os(macOS)
import Foundation
import AppKit

final class AppLauncherService {
    private let fileManager = FileManager.default

    func discoverApps() -> [LauncherItem] {
        let roots = ["/Applications", (NSHomeDirectory() as NSString).appendingPathComponent("Applications")]
        return roots.flatMap { root in
            (try? fileManager.contentsOfDirectory(atPath: root))?.compactMap { name in
                guard name.hasSuffix(".app") else { return nil }
                let full = (root as NSString).appendingPathComponent(name)
                return LauncherItem(name: name.replacingOccurrences(of: ".app", with: ""), path: full, isDirectory: true)
            } ?? []
        }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func launch(item: LauncherItem) {
        NSWorkspace.shared.openFile(item.path)
    }

    func openPath(_ path: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }
}
#endif
