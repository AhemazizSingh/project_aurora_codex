import XCTest
@testable import FinanceOS

final class InsightEngineTests: XCTestCase {
    func testExceededBudgetIsCriticalAndFirst() {
        let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        let budget = Budget(name: "Food", amount: 500, period: .monthly, category: food)
        let expense = FinancialTransaction(type: .expense, amount: 600)
        expense.category = food

        let insights = InsightEngine.generate(budgets: [budget], goals: [], transactions: [expense])

        XCTAssertEqual(insights.first?.priority, .critical)
        XCTAssertTrue(insights.first?.title.contains("exceeded") == true)
    }

    func testUnfundedActiveGoalGetsSuggestion() {
        let fund = Account(name: "Fund", type: .emergencyFund)
        let goal = Goal(title: "Vacation", targetAmount: 10_000, deadline: Calendar.current.date(byAdding: .month, value: 4, to: .now)!)
        goal.linkedAccount = fund

        let insights = InsightEngine.generate(budgets: [], goals: [goal], transactions: [])

        XCTAssertTrue(insights.contains { $0.title.contains("Start your Vacation") })
    }
}
