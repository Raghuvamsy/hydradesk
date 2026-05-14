import Foundation

@MainActor
final class TasksService {
    private(set) var tasks: [TaskItem] = Persistence.load([TaskItem].self, from: "tasks.json", fallback: [])

    func addTask(_ title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        tasks.insert(.init(id: UUID(), title: trimmed, done: false, createdAt: Date()), at: 0)
        Persistence.save(tasks, to: "tasks.json")
    }

    func toggle(_ task: TaskItem) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].done.toggle()
        Persistence.save(tasks, to: "tasks.json")
    }
}
