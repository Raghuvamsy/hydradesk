#if os(macOS)
import SwiftUI
import AppKit

@MainActor
final class MenuBarController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()

    init(appViewModel: AppViewModel) {
        super.init()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 320, height: 220)
        popover.contentViewController = NSHostingController(rootView: MenuBarPopoverView(viewModel: appViewModel))

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "drop", accessibilityDescription: "HydraDesk")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
#endif
