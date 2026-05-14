#if os(macOS)
import Foundation
import AppKit

@MainActor
final class QuickSettingsService {
    var isDarkMode: Bool {
        get { UserDefaults.standard.bool(forKey: "darkMode") }
        set {
            UserDefaults.standard.set(newValue, forKey: "darkMode")
            NSApp.appearance = newValue ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
        }
    }

    var localFocusMode: Bool {
        get { UserDefaults.standard.bool(forKey: "localFocusMode") }
        set { UserDefaults.standard.set(newValue, forKey: "localFocusMode") }
    }

    var brightness: Double {
        get { UserDefaults.standard.double(forKey: "brightness") }
        set { UserDefaults.standard.set(newValue, forKey: "brightness") }
    }

    var volume: Double {
        get { UserDefaults.standard.double(forKey: "volume") }
        set { UserDefaults.standard.set(newValue, forKey: "volume") }
    }
}
#endif
