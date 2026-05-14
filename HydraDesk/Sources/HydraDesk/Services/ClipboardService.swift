#if os(macOS)
import Foundation
import AppKit

@MainActor
final class ClipboardService {
    private let pasteboard = NSPasteboard.general
    private var changeCount: Int
    private(set) var items: [ClipboardItem]

    init() {
        self.changeCount = pasteboard.changeCount
        self.items = Persistence.load([ClipboardItem].self, from: "clipboard.json", fallback: [])
    }

    func poll(maxItems: Int = 100) {
        guard pasteboard.changeCount != changeCount else { return }
        changeCount = pasteboard.changeCount

        var newItem: ClipboardItem?
        if let text = pasteboard.string(forType: .string), !text.isEmpty {
            newItem = ClipboardItem(id: UUID(), text: text, imagePNGBase64: nil, createdAt: Date(), isPinned: false)
        } else if let data = pasteboard.data(forType: .tiff), let image = NSImage(data: data), let tiff = image.tiffRepresentation {
            newItem = ClipboardItem(id: UUID(), text: nil, imagePNGBase64: tiff.base64EncodedString(), createdAt: Date(), isPinned: false)
        }

        guard let item = newItem else { return }
        items.removeAll { $0.text == item.text && $0.imagePNGBase64 == item.imagePNGBase64 }
        items.insert(item, at: 0)

        let pinned = items.filter(\.isPinned)
        let unpinned = items.filter { !$0.isPinned }
        items = pinned + Array(unpinned.prefix(max(0, maxItems - pinned.count)))
        Persistence.save(items, to: "clipboard.json")
    }

    func setPinned(id: UUID, pinned: Bool) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].isPinned = pinned
        Persistence.save(items, to: "clipboard.json")
    }

    func cleanupOlderThan(days: Int) {
        let threshold = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? .distantPast
        items.removeAll { !$0.isPinned && $0.createdAt < threshold }
        Persistence.save(items, to: "clipboard.json")
    }
}
#endif
