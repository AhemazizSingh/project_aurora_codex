import XCTest
import SwiftData
@testable import FinanceOS

@MainActor
final class TransactionServiceTests: XCTestCase {
    func testCreateExpensePersistsMovementAndUpdatesBalance() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let bank = Account(name: "Bank", type: .bank, openingBalance: 1_000)
        let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        context.insert(bank)
        context.insert(food)
        try context.save()

        try TransactionService().create(type: .expense, amount: 125, currencyCode: "INR", date: .now, notes: "Lunch", sourceAccount: bank, destinationAccount: nil, category: food, in: context)

        let transactions = try context.fetch(FetchDescriptor<FinancialTransaction>())
        XCTAssertEqual(transactions.count, 1)
        XCTAssertEqual(transactions.first?.type, .expense)
        XCTAssertEqual(bank.currentBalance, 875)
    }

    func testSoftDeleteReversesBalanceWithoutHardDeletingRecord() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let bank = Account(name: "Bank", type: .bank, openingBalance: 1_000)
        let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        context.insert(bank)
        context.insert(food)
        try context.save()
        try TransactionService().create(type: .expense, amount: 200, currencyCode: "INR", date: .now, notes: "", sourceAccount: bank, destinationAccount: nil, category: food, in: context)
        let transaction = try XCTUnwrap(context.fetch(FetchDescriptor<FinancialTransaction>()).first)

        try TransactionService().softDelete(transaction, in: context)

        XCTAssertTrue(transaction.isActive == false)
        XCTAssertEqual(bank.currentBalance, 1_000)
        XCTAssertEqual(try context.fetch(FetchDescriptor<FinancialTransaction>()).count, 1)
    }

    func testSavingsDoesNotChangeCombinedAssetValue() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let bank = Account(name: "Bank", type: .bank, openingBalance: 2_000)
        let fund = Account(name: "Emergency Fund", type: .emergencyFund, openingBalance: 500)
        context.insert(bank)
        context.insert(fund)
        try context.save()

        try TransactionService().create(type: .savings, amount: 750, currencyCode: "INR", date: .now, notes: "", sourceAccount: bank, destinationAccount: fund, category: nil, in: context)

        XCTAssertEqual(bank.currentBalance + fund.currentBalance, 2_500)
        XCTAssertEqual(bank.currentBalance, 1_250)
        XCTAssertEqual(fund.currentBalance, 1_250)
    }

    func testUpdateReversesOldBalanceImpactBeforeApplyingNewValue() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let bank = Account(name: "Bank", type: .bank, openingBalance: 1_000)
        let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        context.insert(bank); context.insert(food); try context.save()
        let service = TransactionService()
        try service.create(type: .expense, amount: 100, currencyCode: "INR", date: .now, notes: "", sourceAccount: bank, destinationAccount: nil, category: food, in: context)
        let transaction = try XCTUnwrap(context.fetch(FetchDescriptor<FinancialTransaction>()).first)

        try service.update(transaction, type: .expense, amount: 250, currencyCode: "INR", date: .now, notes: "Updated", sourceAccount: bank, destinationAccount: nil, category: food, labels: [], in: context)

        XCTAssertEqual(bank.currentBalance, 750)
        XCTAssertEqual(transaction.amount, 250)
    }

    func testRestoreReappliesSoftDeletedTransaction() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let bank = Account(name: "Bank", type: .bank, openingBalance: 1_000)
        let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#EF4444")
        context.insert(bank); context.insert(food); try context.save()
        let service = TransactionService()
        try service.create(type: .expense, amount: 100, currencyCode: "INR", date: .now, notes: "", sourceAccount: bank, destinationAccount: nil, category: food, in: context)
        let transaction = try XCTUnwrap(context.fetch(FetchDescriptor<FinancialTransaction>()).first)
        try service.softDelete(transaction, in: context)

        try service.restore(transaction, in: context)

        XCTAssertTrue(transaction.isActive)
        XCTAssertEqual(bank.currentBalance, 900)
    }
}
