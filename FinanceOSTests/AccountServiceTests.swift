import XCTest
import SwiftData
@testable import FinanceOS

@MainActor
final class AccountServiceTests: XCTestCase {
    func testCreateStoresNewAccount() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let service = AccountService()

        try service.create(name: " Emergency Fund ", type: .emergencyFund, currencyCode: "INR", openingBalance: 5_000, in: context)

        let accounts = try context.fetch(FetchDescriptor<Account>())
        XCTAssertEqual(accounts.count, 1)
        XCTAssertEqual(accounts.first?.name, "Emergency Fund")
        XCTAssertEqual(accounts.first?.currentBalance, 5_000)
    }

    func testCreateRejectsInvalidAccount() throws {
        let container = PersistenceController.previewContainer()
        let service = AccountService()

        XCTAssertThrowsError(try service.create(name: " ", type: .bank, currencyCode: "INR", openingBalance: 0, in: container.mainContext)) { error in
            XCTAssertEqual(error as? AccountValidationError, .missingName)
        }
    }

    func testArchivePreservesAccountAndBalance() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let account = Account(name: "Primary Bank", type: .bank, openingBalance: 2_000)
        context.insert(account)
        try context.save()

        try AccountService().archive(account, in: context)

        XCTAssertTrue(account.isArchived)
        XCTAssertEqual(account.currentBalance, 2_000)
    }
}
