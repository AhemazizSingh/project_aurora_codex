import Foundation
import SwiftData

/// Immutable financial intent. Deletions are soft deletes to preserve audit history.
@Model
final class FinancialTransaction {
    @Attribute(.unique) var id: UUID
    var typeRawValue: String
    var amount: Decimal
    var currencyCode: String
    var date: Date
    var notes: String
    var deletedAt: Date?
    var createdAt: Date
    var updatedAt: Date
    var sourceAccount: Account?
    var destinationAccount: Account?
    var category: Category?
    var labels: [TransactionLabel] = []

    init(id: UUID = UUID(), type: TransactionType, amount: Decimal, currencyCode: String = "INR", date: Date = .now, notes: String = "") {
        self.id = id
        self.typeRawValue = type.rawValue
        self.amount = amount
        self.currencyCode = currencyCode
        self.date = date
        self.notes = notes
        self.createdAt = .now
        self.updatedAt = .now
    }

    var type: TransactionType { TransactionType(rawValue: typeRawValue) ?? .expense }
    var isActive: Bool { deletedAt == nil }
}
