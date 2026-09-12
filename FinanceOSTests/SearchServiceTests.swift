import XCTest
@testable import FinanceOS

final class SearchServiceTests: XCTestCase {
    func testSearchMatchesTransactionLabelNoteAndAmount() {
        let office = TransactionLabel(name: "Office")
        let transaction = FinancialTransaction(type: .expense, amount: 250, notes: "Team lunch")
        transaction.labels = [office]

        XCTAssertEqual(SearchService.search(query: "office", transactions: [transaction], accounts: [], categories: [], labels: [], goals: [], budgets: []).count, 1)
        XCTAssertEqual(SearchService.search(query: "lunch", transactions: [transaction], accounts: [], categories: [], labels: [], goals: [], budgets: []).count, 1)
        XCTAssertEqual(SearchService.search(query: "250", transactions: [transaction], accounts: [], categories: [], labels: [], goals: [], budgets: []).count, 1)
    }

    func testSearchExcludesArchivedItemsAndDeletedTransactions() {
        let account = Account(name: "Old Bank", type: .bank)
        account.isArchived = true
        let transaction = FinancialTransaction(type: .expense, amount: 100, notes: "Old Bank")
        transaction.deletedAt = .now

        XCTAssertTrue(SearchService.search(query: "old", transactions: [transaction], accounts: [account], categories: [], labels: [], goals: [], budgets: []).isEmpty)
    }
}
