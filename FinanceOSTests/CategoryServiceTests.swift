import XCTest
import SwiftData
@testable import FinanceOS

@MainActor
final class CategoryServiceTests: XCTestCase {
    func testMergeReassignsTransactionsAndArchivesSource() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let bank = Account(name: "Bank", type: .bank, openingBalance: 1_000)
        let dining = Category(name: "Dining", iconName: "fork.knife", colorHex: "#EF4444")
        let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        let transaction = FinancialTransaction(type: .expense, amount: 100)
        transaction.sourceAccount = bank
        transaction.category = dining
        context.insert(bank)
        context.insert(dining)
        context.insert(food)
        context.insert(transaction)
        try context.save()

        try CategoryService().merge(dining, into: food, in: context)

        XCTAssertTrue(dining.isArchived)
        XCTAssertEqual(transaction.category?.id, food.id)
    }

    func testDeleteRejectsCategoryUsedByTransaction() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let bank = Account(name: "Bank", type: .bank, openingBalance: 1_000)
        let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        let transaction = FinancialTransaction(type: .expense, amount: 100)
        transaction.sourceAccount = bank
        transaction.category = food
        context.insert(bank)
        context.insert(food)
        context.insert(transaction)
        try context.save()

        XCTAssertThrowsError(try CategoryService().deleteUnused(food, in: context)) { error in
            XCTAssertEqual(error as? CategoryValidationError, .categoryInUse)
        }
    }

    func testCreateRejectsDuplicateNamesRegardlessOfCase() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        context.insert(Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444"))
        try context.save()

        XCTAssertThrowsError(try CategoryService().create(name: "food", iconName: "fork.knife", colorHex: "#EF4444", in: context)) { error in
            XCTAssertEqual(error as? CategoryValidationError, .duplicateName)
        }
    }
}
