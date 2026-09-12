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
        importSessionID: String? = nil,
        in context: ModelContext
    ) throws {
        let transaction = FinancialTransaction(type: type, amount: amount, currencyCode: currencyCode, date: date, notes: notes)
        transaction.sourceAccount = sourceAccount
        transaction.destinationAccount = destinationAccount
        transaction.category = category
        transaction.labels = labels
        transaction.importSessionID = importSessionID
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

    func restore(_ transaction: FinancialTransaction, in context: ModelContext) throws {
        guard !transaction.isActive else { return }
        transaction.deletedAt = nil
        do {
            try engine.apply(transaction)
            try context.save()
        } catch {
            transaction.deletedAt = .now
            throw error
        }
    }

    func update(
        _ transaction: FinancialTransaction,
        type: TransactionType,
        amount: Decimal,
        currencyCode: String,
        date: Date,
        notes: String,
        sourceAccount: Account?,
        destinationAccount: Account?,
        category: Category?,
        labels: [TransactionLabel],
        in context: ModelContext
    ) throws {
        guard transaction.isActive else { return }
        let oldType = transaction.typeRawValue
        let oldAmount = transaction.amount
        let oldCurrency = transaction.currencyCode
        let oldDate = transaction.date
        let oldNotes = transaction.notes
        let oldSource = transaction.sourceAccount
        let oldDestination = transaction.destinationAccount
        let oldCategory = transaction.category
        let oldLabels = transaction.labels
        engine.reverse(transaction)
        transaction.typeRawValue = type.rawValue
        transaction.amount = amount
        transaction.currencyCode = currencyCode
        transaction.date = date
        transaction.notes = notes
        transaction.sourceAccount = sourceAccount
        transaction.destinationAccount = destinationAccount
        transaction.category = category
        transaction.labels = labels
        do {
            try engine.apply(transaction)
            try context.save()
        } catch {
            engine.reverse(transaction)
            transaction.typeRawValue = oldType
            transaction.amount = oldAmount
            transaction.currencyCode = oldCurrency
            transaction.date = oldDate
            transaction.notes = oldNotes
            transaction.sourceAccount = oldSource
            transaction.destinationAccount = oldDestination
            transaction.category = oldCategory
            transaction.labels = oldLabels
            try? engine.apply(transaction)
            throw error
        }
    }
}
