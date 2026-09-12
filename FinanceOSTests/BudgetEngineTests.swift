import XCTest
import SwiftData
@testable import FinanceOS

@MainActor
final class BudgetEngineTests: XCTestCase {
    func testMonthlyBudgetSubtractsRefundsAndIgnoresTransfers() {
        let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        let budget = Budget(name: "Food", amount: 1_000, period: .monthly, category: food)
        let expense = FinancialTransaction(type: .expense, amount: 400)
        expense.category = food
        let refund = FinancialTransaction(type: .refund, amount: 100)
        refund.category = food
        let transfer = FinancialTransaction(type: .transfer, amount: 250)
        transfer.category = food

        XCTAssertEqual(BudgetEngine.spent(for: budget, transactions: [expense, refund, transfer]), 300)
    }

    func testBudgetExcludesTransactionsOutsideCurrentPeriod() {
        let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        let budget = Budget(name: "Food", amount: 1_000, period: .monthly, category: food)
        let lastMonth = FinancialTransaction(type: .expense, amount: 600, date: Calendar.current.date(byAdding: .month, value: -1, to: .now)!)
        lastMonth.category = food

        XCTAssertEqual(BudgetEngine.spent(for: budget, transactions: [lastMonth]), 0)
    }

    func testCustomBudgetRequiresValidDateRange() throws {
        let container = PersistenceController.previewContainer()
        let category = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        XCTAssertThrowsError(try BudgetService().create(name: "Custom", amount: 1_000, period: .custom, category: category, customStartDate: .now, customEndDate: Calendar.current.date(byAdding: .day, value: -1, to: .now), in: container.mainContext)) { error in
            XCTAssertEqual(error as? BudgetValidationError, .invalidCustomRange)
        }
    }
}
