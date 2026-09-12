import XCTest
import SwiftData
@testable import FinanceOS

@MainActor
final class GoalServiceTests: XCTestCase {
    func testContributionMovesMoneyAndUpdatesGoalProgress() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let bank = Account(name: "Bank", type: .bank, openingBalance: 2_000)
        let fund = Account(name: "Goal Fund", type: .emergencyFund)
        context.insert(bank)
        context.insert(fund)
        try context.save()
        try GoalService().create(title: "Vacation", targetAmount: 1_000, deadline: Calendar.current.date(byAdding: .month, value: 6, to: .now)!, priority: .medium, linkedAccount: fund, notes: "", in: context)
        let goal = try XCTUnwrap(context.fetch(FetchDescriptor<Goal>()).first)

        try GoalService().contribute(amount: 400, from: bank, to: goal, currencyCode: "INR", in: context)

        XCTAssertEqual(bank.currentBalance, 1_600)
        XCTAssertEqual(fund.currentBalance, 400)
        XCTAssertEqual(goal.savedAmount, 400)
        XCTAssertEqual(goal.status, .active)
    }

    func testContributionCompletesGoalAtTarget() throws {
        let container = PersistenceController.previewContainer()
        let context = container.mainContext
        let bank = Account(name: "Bank", type: .bank, openingBalance: 1_000)
        let fund = Account(name: "Goal Fund", type: .emergencyFund)
        let goal = Goal(title: "Laptop", targetAmount: 500, deadline: Calendar.current.date(byAdding: .month, value: 3, to: .now)!)
        goal.linkedAccount = fund
        context.insert(bank)
        context.insert(fund)
        context.insert(goal)
        try context.save()

        try GoalService().contribute(amount: 500, from: bank, to: goal, currencyCode: "INR", in: context)

        XCTAssertEqual(goal.status, .completed)
        XCTAssertEqual(goal.progress, 1)
        XCTAssertEqual(bank.currentBalance + fund.currentBalance, 1_000)
    }

    func testCreateRejectsNonAssetGoalAccount() throws {
        let container = PersistenceController.previewContainer()
        let loan = Account(name: "Loan", type: .loan)
        XCTAssertThrowsError(try GoalService().create(title: "Emergency Fund", targetAmount: 5_000, deadline: Calendar.current.date(byAdding: .month, value: 2, to: .now)!, priority: .high, linkedAccount: loan, notes: "", in: container.mainContext)) { error in
            XCTAssertEqual(error as? GoalValidationError, .missingLinkedAccount)
        }
    }
}
