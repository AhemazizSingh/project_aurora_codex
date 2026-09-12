import Foundation

enum TransactionSortOrder: String, CaseIterable, Identifiable {
    case newest, oldest, highestAmount, lowestAmount
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .newest: "Newest first"
        case .oldest: "Oldest first"
        case .highestAmount: "Highest amount"
        case .lowestAmount: "Lowest amount"
        }
    }
}

struct TransactionFilter {
    var type: TransactionType?
    var accountID: UUID?
    var categoryID: UUID?
    var dateRange: DateInterval?
    var sortOrder: TransactionSortOrder = .newest

    func apply(to transactions: [FinancialTransaction]) -> [FinancialTransaction] {
        let filtered = transactions.filter { transaction in
            transaction.isActive
                && (type.map { transaction.type == $0 } ?? true)
                && (categoryID.map { transaction.category?.id == $0 } ?? true)
                && (accountID.map { transaction.sourceAccount?.id == $0 || transaction.destinationAccount?.id == $0 } ?? true)
                && (dateRange.map { $0.contains(transaction.date) } ?? true)
        }
        switch sortOrder {
        case .newest: filtered.sorted { $0.date > $1.date }
        case .oldest: filtered.sorted { $0.date < $1.date }
        case .highestAmount: filtered.sorted { $0.amount > $1.amount }
        case .lowestAmount: filtered.sorted { $0.amount < $1.amount }
        }
    }
}
