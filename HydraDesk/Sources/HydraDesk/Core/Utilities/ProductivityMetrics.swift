import Foundation

enum ProductivityMetrics {
    static func completionRate(completed: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }
}
