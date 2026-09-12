import XCTest
@testable import FinanceOS

final class AnalyticsServiceTests: XCTestCase {
    func testSummarySeparatesExpensesFromSavingsAndTransfers() {
        let bank = Account(name: "Bank", type: .bank, openingBalance: 700)
        let fund = Account(name: "Fund", type: .emergencyFund, openingBalance: 300)
        let card = Account(name: "Card", type: .creditCard, openingBalance: 100)
        let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        let income = FinancialTransaction(type: .income, amount: 1_000)
        let expense = FinancialTransaction(type: .expense, amount: 250); expense.category = food
        let refund = FinancialTransaction(type: .refund, amount: 50); refund.category = food
        let savings = FinancialTransaction(type: .savings, amount: 300)
        let transfer = FinancialTransaction(type: .transfer, amount: 100)
        let investment = FinancialTransaction(type: .investment, amount: 200)

        let result = AnalyticsService.summary(accounts: [bank, fund, card], transactions: [income, expense, refund, savings, transfer, investment])

        XCTAssertEqual(result.netWorth, 900)
        XCTAssertEqual(result.income, 1_000)
        XCTAssertEqual(result.expenses, 200)
        XCTAssertEqual(result.cashFlow, 800)
        XCTAssertEqual(result.savings, 300)
        XCTAssertEqual(result.investments, 200)
        XCTAssertEqual(result.categorySpending.first?.amount, 200)
    }

    func testSoftDeletedTransactionsAreIgnored() {
        let account = Account(name: "Bank", type: .bank, openingBalance: 100)
        let expense = FinancialTransaction(type: .expense, amount: 50)
        expense.deletedAt = .now

        let result = AnalyticsService.summary(accounts: [account], transactions: [expense])

        XCTAssertEqual(result.expenses, 0)
        XCTAssertEqual(result.cashFlow, 0)
    }
}
