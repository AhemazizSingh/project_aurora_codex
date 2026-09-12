import Foundation

struct FinancialSummary {
    let netWorth: Decimal
    let income: Decimal
    let expenses: Decimal
    let savings: Decimal
    let investments: Decimal
    let cashFlow: Decimal
    let categorySpending: [(category: Category, amount: Decimal)]
}

/// One source of truth for dashboard and analytics calculations.
/// Savings, investments, and transfers never inflate expenses or cash flow.
enum AnalyticsService {
    static func summary(accounts: [Account], transactions: [FinancialTransaction], range: DateInterval? = nil) -> FinancialSummary {
        let active = transactions.filter { transaction in
            transaction.isActive && (range.map { $0.contains(transaction.date) } ?? true)
        }
        let income = active.filter { $0.type.isIncome }.reduce(Decimal.zero) { $0 + $1.amount }
        let expenses = active.reduce(Decimal.zero) { total, item in
            switch item.type { case .expense: total + item.amount; case .refund: total - item.amount; default: total }
        }
        let categories = Dictionary(grouping: active.filter { $0.type == .expense || $0.type == .refund }, by: { $0.category?.id })
            .compactMap { _, entries -> (Category, Decimal)? in
                guard let category = entries.first?.category else { return nil }
                let amount = entries.reduce(Decimal.zero) { $0 + ($1.type == .refund ? -$1.amount : $1.amount) }
                return amount > 0 ? (category, amount) : nil
            }
            .sorted { $0.1 > $1.1 }
        return FinancialSummary(
            netWorth: accounts.filter { !$0.isArchived }.reduce(Decimal.zero) { $0 + $1.netWorthContribution },
            income: income,
            expenses: max(expenses, 0),
            savings: active.filter { $0.type == .savings }.reduce(Decimal.zero) { $0 + $1.amount },
            investments: active.filter { $0.type == .investment }.reduce(Decimal.zero) { $0 + $1.amount },
            cashFlow: income - max(expenses, 0),
            categorySpending: categories
        )
    }
}
