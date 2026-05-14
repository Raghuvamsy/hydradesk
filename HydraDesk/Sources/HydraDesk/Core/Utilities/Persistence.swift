import Foundation

enum Persistence {
    static func appSupportDirectory() -> URL {
        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let folder = base.appendingPathComponent("HydraDesk", isDirectory: true)
        try? fm.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    static func load<T: Decodable>(_ type: T.Type, from file: String, fallback: T) -> T {
        let url = appSupportDirectory().appendingPathComponent(file)
        guard let data = try? Data(contentsOf: url), let value = try? JSONDecoder().decode(T.self, from: data) else {
            return fallback
        }
        return value
    }

    static func save<T: Encodable>(_ value: T, to file: String) {
        let url = appSupportDirectory().appendingPathComponent(file)
        guard let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: url, options: [.atomic])
    }
}
