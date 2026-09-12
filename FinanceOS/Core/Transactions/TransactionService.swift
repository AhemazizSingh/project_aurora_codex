import Foundation
import SwiftData

/// Persists transactions and applies their balance impact as one operation.
@MainActor
final class TransactionService {
    private let engine = TransactionEngine()

    func create(
        type: TransactionType,
        amount: Decimal,
        currencyCode: String,
        date: Date,
        notes: String,
        sourceAccount: Account?,
        destinationAccount: Account?,
        category: Category?,
        labels: [TransactionLabel] = [],
        in context: ModelContext
    ) throws {
        let transaction = FinancialTransaction(type: type, amount: amount, currencyCode: currencyCode, date: date, notes: notes)
        transaction.sourceAccount = sourceAccount
        transaction.destinationAccount = destinationAccount
        transaction.category = category
        transaction.labels = labels
        try engine.apply(transaction)
        context.insert(transaction)
        do {
            try context.save()
        } catch {
            engine.reverse(transaction)
            context.delete(transaction)
            throw error
        }
    }

    func softDelete(_ transaction: FinancialTransaction, in context: ModelContext) throws {
        guard transaction.isActive else { return }
        engine.reverse(transaction)
        transaction.deletedAt = .now
        transaction.updatedAt = .now
        do {
            try context.save()
        } catch {
            transaction.deletedAt = nil
            engine.apply(transaction)
            throw error
        }
    }
}
