import Foundation
import SwiftData

@MainActor
final class TransactionImportService {
    private let transactionService = TransactionService()

    func validationMessages(for rows: [CSVImportRow], accounts: [Account], categories: [Category], existing: [FinancialTransaction]) -> [String] {
        rows.compactMap { row in
            let source = accounts.first { $0.name.localizedCaseInsensitiveCompare(row.sourceAccountName) == .orderedSame }
            let destination = accounts.first { $0.name.localizedCaseInsensitiveCompare(row.destinationAccountName) == .orderedSame }
            let category = categories.first { $0.name.localizedCaseInsensitiveCompare(row.categoryName) == .orderedSame }
            if row.type == .expense, source == nil { return "Row \(row.lineNumber): expense source account not found." }
            if row.type == .expense, category == nil { return "Row \(row.lineNumber): expense category not found." }
            if row.type != .expense, destination == nil { return "Row \(row.lineNumber): destination account not found." }
            if row.type.isMovement, source == nil { return "Row \(row.lineNumber): source account not found." }
            if existing.contains(where: { isDuplicate(row, transaction: $0) }) { return "Row \(row.lineNumber): appears to be a duplicate of an existing transaction." }
            return nil
        }
    }

    func `import`(_ rows: [CSVImportRow], accounts: [Account], categories: [Category], labels: [TransactionLabel], into context: ModelContext) throws -> String {
        let sessionID = UUID().uuidString
        for row in rows {
            let source = accounts.first { $0.name.localizedCaseInsensitiveCompare(row.sourceAccountName) == .orderedSame }
            let destination = accounts.first { $0.name.localizedCaseInsensitiveCompare(row.destinationAccountName) == .orderedSame }
            let category = categories.first { $0.name.localizedCaseInsensitiveCompare(row.categoryName) == .orderedSame }
            let matchedLabels = labels.filter { label in row.labelNames.contains { name in name.localizedCaseInsensitiveCompare(label.name) == .orderedSame } }
            try transactionService.create(type: row.type, amount: row.amount, currencyCode: row.currencyCode, date: row.date, notes: row.notes, sourceAccount: source, destinationAccount: destination, category: category, labels: matchedLabels, importSessionID: sessionID, in: context)
        }
        return sessionID
    }

    func undo(sessionID: String, transactions: [FinancialTransaction], in context: ModelContext) throws {
        for transaction in transactions where transaction.isActive && transaction.importSessionID == sessionID { try transactionService.softDelete(transaction, in: context) }
    }

    private func isDuplicate(_ row: CSVImportRow, transaction: FinancialTransaction) -> Bool {
        transaction.isActive && transaction.type == row.type && transaction.amount == row.amount && Calendar.current.isDate(transaction.date, inSameDayAs: row.date) && transaction.notes == row.notes
    }
}
