import Foundation

enum BudgetPeriod: String, CaseIterable, Identifiable {
    case weekly, monthly, quarterly, yearly, custom
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}
