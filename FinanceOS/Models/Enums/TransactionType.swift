import Foundation

/// Money movements recognized by FinanceOS. Analytics must use these semantics.
enum TransactionType: String, CaseIterable, Codable, Identifiable {
    case expense, income, savings, investment, transfer, refund, interest, dividend, loan, adjustment

    var id: String { rawValue }
    var isExpense: Bool { self == .expense }
    var isIncome: Bool { self == .income || self == .interest || self == .dividend }
    var isMovement: Bool { self == .savings || self == .investment || self == .transfer }
    var requiresDestination: Bool { isMovement || self == .loan }

    var displayName: String { rawValue.capitalized }

    var symbolName: String {
        switch self {
        case .expense: "arrow.up.circle.fill"
        case .income: "arrow.down.circle.fill"
        case .savings: "banknote.fill"
        case .investment: "chart.line.uptrend.xyaxis.circle.fill"
        case .transfer: "arrow.left.arrow.right.circle.fill"
        case .refund: "arrow.uturn.left.circle.fill"
        case .interest: "percent"
        case .dividend: "dollarsign.circle.fill"
        case .loan: "building.columns.fill"
        case .adjustment: "slider.horizontal.3"
        }
    }
}
