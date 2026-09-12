import Foundation
import SwiftData

@Model
final class RecurringTransactionRule: Identifiable {
    @Attribute(.unique) var id: UUID
    var typeRawValue: String
    var amount: Decimal
    var currencyCode: String
    var notes: String
    var frequencyRawValue: String
    var nextDueDate: Date
    var isActive: Bool
    var createdAt: Date
    var sourceAccount: Account?
    var destinationAccount: Account?
    var category: Category?
    var labels: [TransactionLabel] = []

    init(type: TransactionType, amount: Decimal, currencyCode: String, notes: String, frequency: RecurrenceFrequency, nextDueDate: Date) {
        self.id = UUID(); self.typeRawValue = type.rawValue; self.amount = amount; self.currencyCode = currencyCode; self.notes = notes; self.frequencyRawValue = frequency.rawValue; self.nextDueDate = nextDueDate; self.isActive = true; self.createdAt = .now
    }
    var type: TransactionType { TransactionType(rawValue: typeRawValue) ?? .expense }
    var frequency: RecurrenceFrequency { RecurrenceFrequency(rawValue: frequencyRawValue) ?? .monthly }
}
