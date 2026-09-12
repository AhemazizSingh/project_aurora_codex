import XCTest
@testable import FinanceOS

final class CSVExportServiceTests: XCTestCase {
    func testExportEscapesQuotesAndPreservesKeyFields() {
        let account = Account(name: "Main, Bank", type: .bank)
        let label = TransactionLabel(name: "Weekend")
        let transaction = FinancialTransaction(type: .expense, amount: 250, notes: "Dinner at \"Cafe\"")
        transaction.sourceAccount = account
        transaction.labels = [label]

        let csv = CSVExportService.transactionsCSV([transaction])

        XCTAssertTrue(csv.contains("\"Main, Bank\""))
        XCTAssertTrue(csv.contains("Dinner at \"\"Cafe\"\""))
        XCTAssertTrue(csv.contains("Weekend"))
    }

    func testExportExcludesSoftDeletedTransactions() {
        let transaction = FinancialTransaction(type: .income, amount: 1_000)
        transaction.deletedAt = .now

        let csv = CSVExportService.transactionsCSV([transaction])

        XCTAssertEqual(csv.components(separatedBy: "\n").count, 1)
    }
}
