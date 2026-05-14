import Foundation

@MainActor
final class NotificationHubService {
    private(set) var history: [NotificationRecord] = Persistence.load([NotificationRecord].self, from: "notifications.json", fallback: [])

    func add(title: String, message: String) {
        history.insert(.init(id: UUID(), title: title, message: message, createdAt: Date()), at: 0)
        history = Array(history.prefix(300))
        Persistence.save(history, to: "notifications.json")
    }
}
