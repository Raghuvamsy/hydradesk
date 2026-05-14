import Foundation

struct SystemStatsSnapshot: Equatable {
    var cpuUsage: Double
    var memoryUsedGB: Double
    var memoryTotalGB: Double
    var diskUsedGB: Double
    var diskTotalGB: Double
    var batteryPercent: Double?
    var batteryIsCharging: Bool
    var networkDownKBps: Double
    var networkUpKBps: Double

    static let empty = SystemStatsSnapshot(
        cpuUsage: 0,
        memoryUsedGB: 0,
        memoryTotalGB: 0,
        diskUsedGB: 0,
        diskTotalGB: 0,
        batteryPercent: nil,
        batteryIsCharging: false,
        networkDownKBps: 0,
        networkUpKBps: 0
    )
}

struct LauncherItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let isDirectory: Bool
}

struct ClipboardItem: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String?
    var imagePNGBase64: String?
    var createdAt: Date
    var isPinned: Bool
}

struct NotificationRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var message: String
    var createdAt: Date
}

struct WorkspaceProfile: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var appPaths: [String]
    var createdAt: Date
}

struct TaskItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var done: Bool
    var createdAt: Date
}
