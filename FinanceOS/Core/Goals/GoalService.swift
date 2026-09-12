import Foundation
import SwiftData

enum GoalValidationError: LocalizedError, Equatable {
    case missingTitle, nonPositiveTarget, deadlineMustBeFuture, missingLinkedAccount, goalNotActive

    var errorDescription: String? {
        switch self {
        case .missingTitle: "Give this goal a title."
        case .nonPositiveTarget: "Target amount must be greater than zero."
        case .deadlineMustBeFuture: "Choose a future target date."
        case .missingLinkedAccount: "Choose the savings account for this goal."
        case .goalNotActive: "Only active goals can receive contributions."
        }
    }
}

@MainActor
final class GoalService {
    private let engine = TransactionEngine()

    func create(title: String, targetAmount: Decimal, deadline: Date, priority: GoalPriority, linkedAccount: Account?, notes: String, in context: ModelContext) throws {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTitle.isEmpty else { throw GoalValidationError.missingTitle }
        guard targetAmount > 0 else { throw GoalValidationError.nonPositiveTarget }
        guard deadline > .now else { throw GoalValidationError.deadlineMustBeFuture }
        guard let linkedAccount, linkedAccount.type.isAsset else { throw GoalValidationError.missingLinkedAccount }

        let goal = Goal(title: normalizedTitle, targetAmount: targetAmount, deadline: deadline, priority: priority, notes: notes)
        goal.linkedAccount = linkedAccount
        context.insert(goal)
        try context.save()
    }

    func contribute(amount: Decimal, from sourceAccount: Account?, to goal: Goal, currencyCode: String, date: Date = .now, in context: ModelContext) throws {
        guard goal.status == .active else { throw GoalValidationError.goalNotActive }
        guard let destination = goal.linkedAccount else { throw GoalValidationError.missingLinkedAccount }
        let transaction = FinancialTransaction(type: .savings, amount: amount, currencyCode: currencyCode, date: date, notes: "Goal contribution: \(goal.title)")
        transaction.sourceAccount = sourceAccount
        transaction.destinationAccount = destination
        transaction.goal = goal
        try engine.apply(transaction)
        goal.savedAmount += amount
        if goal.savedAmount >= goal.targetAmount { goal.statusRawValue = GoalStatus.completed.rawValue }
        goal.updatedAt = .now
        context.insert(transaction)
        do { try context.save() }
        catch {
            engine.reverse(transaction)
            goal.savedAmount -= amount
            if goal.status == .completed { goal.statusRawValue = GoalStatus.active.rawValue }
            context.delete(transaction)
            throw error
        }
    }

    func archive(_ goal: Goal, in context: ModelContext) throws {
        goal.statusRawValue = GoalStatus.cancelled.rawValue
        goal.updatedAt = .now
        try context.save()
    }
}
