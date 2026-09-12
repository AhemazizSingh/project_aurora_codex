import Foundation

/// Money movements recognized by FinanceOS. Analytics must use these semantics.
enum TransactionType: String, CaseIterable, Codable, Identifiable {
    case expense, income, savings, investment, transfer, refund, interest, dividend, loan, adjustment

    var id: String { rawValue }
    var isExpense: Bool { self == .expense }
    var isIncome: Bool { self == .income || self == .interest || self == .dividend }
    var isMovement: Bool { self == .savings || self == .investment || self == .transfer }
    var requiresDestination: Bool { isMovement || self == .loan }
}
