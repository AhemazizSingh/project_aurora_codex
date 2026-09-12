import Foundation
import SwiftData

@Model
final class Budget: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Decimal
    var periodRawValue: String
    var customStartDate: Date?
    var customEndDate: Date?
    var warningLevel: Decimal
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date
    var category: Category?

    init(id: UUID = UUID(), name: String, amount: Decimal, period: BudgetPeriod, category: Category?, customStartDate: Date? = nil, customEndDate: Date? = nil, warningLevel: Decimal = 0.8) {
        self.id = id
        self.name = name
        self.amount = amount
        self.periodRawValue = period.rawValue
        self.category = category
        self.customStartDate = customStartDate
        self.customEndDate = customEndDate
        self.warningLevel = warningLevel
        self.isArchived = false
        self.createdAt = .now
        self.updatedAt = .now
    }

    var period: BudgetPeriod { BudgetPeriod(rawValue: periodRawValue) ?? .monthly }
}
