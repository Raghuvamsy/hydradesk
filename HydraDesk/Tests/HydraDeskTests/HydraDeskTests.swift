import Testing
@testable import HydraDesk

@Test("Completion rate handles edge cases")
func completionRate() {
    #expect(ProductivityMetrics.completionRate(completed: 0, total: 0) == 0)
    #expect(ProductivityMetrics.completionRate(completed: 3, total: 10) == 0.3)
    #expect(ProductivityMetrics.completionRate(completed: 10, total: 10) == 1)
}
