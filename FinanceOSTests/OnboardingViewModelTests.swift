import XCTest
import SwiftData
@testable import FinanceOS

@MainActor
final class OnboardingViewModelTests: XCTestCase {
    func testCompletionCreatesInitialAccount() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let viewModel = OnboardingViewModel()
        viewModel.accountName = "Primary Bank"
        viewModel.accountType = .bank
        viewModel.currencyCode = "INR"
        viewModel.openingBalanceText = "1250"

        viewModel.complete(using: context)

        let accounts = try context.fetch(FetchDescriptor<Account>())
        XCTAssertEqual(accounts.count, 1)
        XCTAssertEqual(accounts.first?.name, "Primary Bank")
        XCTAssertEqual(accounts.first?.currentBalance, 1250)
        XCTAssertEqual(accounts.first?.currencyCode, "INR")
    }

    func testCompletionRejectsMissingAccountName() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let viewModel = OnboardingViewModel()
        viewModel.openingBalanceText = "500"

        viewModel.complete(using: context)

        let accounts = try context.fetch(FetchDescriptor<Account>())
        XCTAssertTrue(accounts.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
