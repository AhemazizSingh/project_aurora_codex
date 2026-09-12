import Foundation
import SwiftData

@MainActor
final class RecurringTransactionService {
    private let transactionService = TransactionService()

    func generateDueTransactions(for rule: RecurringTransactionRule, through date: Date = .now, in context: ModelContext) throws -> Int {
        guard rule.isActive else { return 0 }
        var generated = 0
        while rule.nextDueDate <= date {
            try transactionService.create(type: rule.type, amount: rule.amount, currencyCode: rule.currencyCode, date: rule.nextDueDate, notes: rule.notes, sourceAccount: rule.sourceAccount, destinationAccount: rule.destinationAccount, category: rule.category, labels: rule.labels, in: context)
            guard let next = Calendar.current.date(byAdding: rule.frequency.calendarComponent, value: rule.frequency.interval, to: rule.nextDueDate) else { break }
            rule.nextDueDate = next
            generated += 1
        }
        try context.save()
        return generated
    }

    func skipNextOccurrence(for rule: RecurringTransactionRule, in context: ModelContext) throws {
        guard let next = Calendar.current.date(byAdding: rule.frequency.calendarComponent, value: rule.frequency.interval, to: rule.nextDueDate) else { return }
        rule.nextDueDate = next
        try context.save()
    }
}
