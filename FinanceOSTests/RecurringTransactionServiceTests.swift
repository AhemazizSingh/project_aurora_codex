import XCTest
import SwiftData
@testable import FinanceOS

@MainActor
final class RecurringTransactionServiceTests: XCTestCase {
    func testGeneratesEveryDueOccurrenceAndAdvancesRule() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let bank = Account(name: "Bank", type: .bank, openingBalance: 1_000)
        let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        let dueDate = Calendar.current.date(byAdding: .day, value: -2, to: .now)!
        let rule = RecurringTransactionRule(type: .expense, amount: 100, currencyCode: "INR", notes: "Daily meal", frequency: .daily, nextDueDate: dueDate)
        rule.sourceAccount = bank; rule.category = food
        context.insert(bank); context.insert(food); context.insert(rule); try context.save()

        let count = try RecurringTransactionService().generateDueTransactions(for: rule, through: .now, in: context)

        XCTAssertEqual(count, 3)
        XCTAssertEqual(bank.currentBalance, 700)
        XCTAssertTrue(rule.nextDueDate > .now)
    }
}
