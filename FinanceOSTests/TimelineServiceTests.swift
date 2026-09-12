import XCTest
@testable import FinanceOS

final class TimelineServiceTests: XCTestCase {
    func testTimelineExcludesDeletedTransactionsAndIncludesCompletedGoal() {
        let visible = FinancialTransaction(type: .income, amount: 100)
        let deleted = FinancialTransaction(type: .expense, amount: 25)
        deleted.deletedAt = .now
        let goal = Goal(title: "Laptop", targetAmount: 1_000, deadline: Calendar.current.date(byAdding: .month, value: 2, to: .now)!)
        goal.statusRawValue = GoalStatus.completed.rawValue

        let entries = TimelineService.entries(transactions: [visible, deleted], goals: [goal])

        XCTAssertEqual(entries.filter { $0.kind == .transaction }.count, 1)
        XCTAssertTrue(entries.contains { $0.kind == .goalCompleted })
    }
}
