#if os(macOS)
import Foundation
import AppKit

final class WallpaperService {
    func discoverImages() -> [URL] {
        guard let pictures = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first else {
            return []
        }
        let files = (try? FileManager.default.contentsOfDirectory(at: pictures, includingPropertiesForKeys: nil)) ?? []
        return files.filter { ["jpg", "jpeg", "png", "heic"].contains($0.pathExtension.lowercased()) }
    }

    func setWallpaper(_ url: URL) {
        for screen in NSScreen.screens {
            try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
        }
    }
}
#endif
