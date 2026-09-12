import Foundation

enum InsightPriority: Int, Comparable {
    case critical = 0, important = 1, suggestion = 2, achievement = 3
    static func < (lhs: InsightPriority, rhs: InsightPriority) -> Bool { lhs.rawValue < rhs.rawValue }
}

struct FinancialInsight: Identifiable {
    let id = UUID()
    let priority: InsightPriority
    let title: String
    let explanation: String
    let action: String
    let symbolName: String
}

/// Deterministic, offline, explainable recommendations for Version 1.
enum InsightEngine {
    static func generate(budgets: [Budget], goals: [Goal], transactions: [FinancialTransaction], now: Date = .now) -> [FinancialInsight] {
        var insights: [FinancialInsight] = []
        for budget in budgets where !budget.isArchived {
            let spent = BudgetEngine.spent(for: budget, transactions: transactions, now: now)
            let ratio = ((spent / budget.amount) as NSDecimalNumber).doubleValue
            if ratio >= 1 {
                insights.append(FinancialInsight(priority: .critical, title: "\(budget.name) budget exceeded", explanation: "You have spent \(InsightCurrency.string(spent)) against a budget of \(InsightCurrency.string(budget.amount)).", action: "Review spending", symbolName: "exclamationmark.triangle.fill"))
            } else if ratio >= (budget.warningLevel as NSDecimalNumber).doubleValue {
                insights.append(FinancialInsight(priority: .important, title: "\(budget.name) is nearly used", explanation: "\(Int(ratio * 100))% of this budget has been used.", action: "View budget", symbolName: "exclamationmark.circle.fill"))
            }
        }
        for goal in goals where goal.status == .active {
            let days = Calendar.current.dateComponents([.day], from: now, to: goal.deadline).day ?? 0
            if days > 0 && goal.savedAmount == 0 {
                insights.append(FinancialInsight(priority: .suggestion, title: "Start your \(goal.title) goal", explanation: "Your target date is approaching and this goal has no saved amount yet.", action: "Make a contribution", symbolName: "target"))
            }
        }
        let monthRange = Calendar.current.dateInterval(of: .month, for: now)
        let previousMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
        let previousRange = Calendar.current.dateInterval(of: .month, for: previousMonthDate)
        let current = AnalyticsService.summary(accounts: [], transactions: transactions, range: monthRange).expenses
        let previous = AnalyticsService.summary(accounts: [], transactions: transactions, range: previousRange).expenses
        if previous > 0 && current > previous * Decimal(string: "1.15")! {
            let rise = (((current - previous) / previous * 100) as NSDecimalNumber).doubleValue
            insights.append(FinancialInsight(priority: .important, title: "Spending is up \(Int(rise))% this month", explanation: "Your expenses are \(InsightCurrency.string(current - previous)) higher than last month so far.", action: "View analytics", symbolName: "chart.line.uptrend.xyaxis"))
        }
        return insights.sorted { $0.priority < $1.priority }
    }
}

private enum InsightCurrency {
    static func string(_ amount: Decimal) -> String {
        let formatter = NumberFormatter(); formatter.numberStyle = .currency; formatter.currencyCode = UserDefaults.standard.string(forKey: "financeos.currencyCode") ?? "INR"; formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "₹0"
    }
}
