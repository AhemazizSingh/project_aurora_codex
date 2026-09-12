import XCTest
import SwiftData
@testable import FinanceOS

@MainActor
final class LabelServiceTests: XCTestCase {
    func testMergeMovesLabelWithoutDuplicatingDestination() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let source = TransactionLabel(name: "Weekend")
        let destination = TransactionLabel(name: "Personal")
        let transaction = FinancialTransaction(type: .income, amount: 100)
        transaction.labels = [source, destination]
        context.insert(source)
        context.insert(destination)
        context.insert(transaction)
        try context.save()

        try LabelService().merge(source, into: destination, in: context)

        XCTAssertTrue(source.isArchived)
        XCTAssertEqual(transaction.labels.count, 1)
        XCTAssertEqual(transaction.labels.first?.id, destination.id)
    }

    func testDeleteRejectsUsedLabel() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let label = TransactionLabel(name: "Office")
        let transaction = FinancialTransaction(type: .income, amount: 100)
        transaction.labels = [label]
        context.insert(label)
        context.insert(transaction)
        try context.save()

        XCTAssertThrowsError(try LabelService().deleteUnused(label, in: context)) { error in
            XCTAssertEqual(error as? LabelValidationError, .labelInUse)
        }
    }
}
