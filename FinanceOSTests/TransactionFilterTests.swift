import XCTest
@testable import FinanceOS

final class TransactionFilterTests: XCTestCase {
    func testFilterSelectsAccountAndTypeThenSortsByAmount() {
        let bank = Account(name: "Bank", type: .bank)
        let cash = Account(name: "Cash", type: .cash)
        let first = FinancialTransaction(type: .expense, amount: 50); first.sourceAccount = bank
        let second = FinancialTransaction(type: .expense, amount: 200); second.sourceAccount = bank
        let third = FinancialTransaction(type: .income, amount: 500); third.destinationAccount = bank
        let other = FinancialTransaction(type: .expense, amount: 300); other.sourceAccount = cash
        var filter = TransactionFilter(type: .expense, accountID: bank.id)
        filter.sortOrder = .highestAmount

        let result = filter.apply(to: [first, second, third, other])

        XCTAssertEqual(result.map(\.amount), [200, 50])
    }
}
