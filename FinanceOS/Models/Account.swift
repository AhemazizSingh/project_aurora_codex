import Foundation
import SwiftData

@Model
final class Account {
    @Attribute(.unique) var id: UUID
    var name: String
    var typeRawValue: String
    var currencyCode: String
    var openingBalance: Decimal
    var currentBalance: Decimal
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), name: String, type: AccountType, currencyCode: String = "INR", openingBalance: Decimal = 0) {
        self.id = id
        self.name = name
        self.typeRawValue = type.rawValue
        self.currencyCode = currencyCode
        self.openingBalance = openingBalance
        self.currentBalance = openingBalance
        self.isArchived = false
        self.createdAt = .now
        self.updatedAt = .now
    }

    var type: AccountType { AccountType(rawValue: typeRawValue) ?? .other }
    var netWorthContribution: Decimal { type.isAsset ? currentBalance : -currentBalance }
}
