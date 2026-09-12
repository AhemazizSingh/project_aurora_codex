import XCTest
@testable import FinanceOS

final class TransactionEngineTests: XCTestCase {
    private let engine = TransactionEngine()

    func testExpenseReducesAnAssetBalance() throws {
        let bank = Account(name: "Bank", type: .bank, openingBalance: 1_000)
        let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        let transaction = FinancialTransaction(type: .expense, amount: 250)
        transaction.sourceAccount = bank
        transaction.category = food

        try engine.apply(transaction)

        XCTAssertEqual(bank.currentBalance, 750)
        XCTAssertEqual(bank.netWorthContribution, 750)
    }

    func testSavingsMovesMoneyWithoutChangingNetWorth() throws {
        let bank = Account(name: "Bank", type: .bank, openingBalance: 1_000)
        let fund = Account(name: "Emergency Fund", type: .emergencyFund, openingBalance: 500)
        let transaction = FinancialTransaction(type: .savings, amount: 300)
        transaction.sourceAccount = bank
        transaction.destinationAccount = fund
        let netWorthBefore = bank.netWorthContribution + fund.netWorthContribution

        try engine.apply(transaction)

        XCTAssertEqual(bank.currentBalance, 700)
        XCTAssertEqual(fund.currentBalance, 800)
        XCTAssertEqual(bank.netWorthContribution + fund.netWorthContribution, netWorthBefore)
    }

    func testCreditCardExpenseIncreasesLiability() throws {
        let card = Account(name: "Credit Card", type: .creditCard)
        let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        let transaction = FinancialTransaction(type: .expense, amount: 500)
        transaction.sourceAccount = card
        transaction.category = food

        try engine.apply(transaction)

        XCTAssertEqual(card.currentBalance, 500)
        XCTAssertEqual(card.netWorthContribution, -500)
    }

    func testLoanLeavesNetWorthUnchanged() throws {
        let loan = Account(name: "Education Loan", type: .loan)
        let bank = Account(name: "Bank", type: .bank)
        let transaction = FinancialTransaction(type: .loan, amount: 50_000)
        transaction.sourceAccount = loan
        transaction.destinationAccount = bank

        try engine.apply(transaction)

        XCTAssertEqual(loan.currentBalance, 50_000)
        XCTAssertEqual(bank.currentBalance, 50_000)
        XCTAssertEqual(loan.netWorthContribution + bank.netWorthContribution, 0)
    }

    func testSavingsRequiresTwoDifferentAccounts() {
        let bank = Account(name: "Bank", type: .bank, openingBalance: 1_000)
        let transaction = FinancialTransaction(type: .savings, amount: 100)
        transaction.sourceAccount = bank
        transaction.destinationAccount = bank

        XCTAssertThrowsError(try engine.apply(transaction)) { error in
            XCTAssertEqual(error as? TransactionValidationError, .identicalAccounts)
        }
    }
}
