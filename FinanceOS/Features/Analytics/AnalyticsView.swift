import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Query private var accounts: [Account]
    @Query(sort: \FinancialTransaction.date, order: .reverse) private var transactions: [FinancialTransaction]
    private var summary: FinancialSummary { AnalyticsService.summary(accounts: accounts, transactions: transactions, range: Calendar.current.dateInterval(of: .month, for: .now)) }

    var body: some View {
        List {
            Section("This month") {
                AnalyticsMetric(title: "Income", amount: summary.income, color: AppTheme.income, symbol: "arrow.down.circle.fill")
                AnalyticsMetric(title: "Expenses", amount: summary.expenses, color: AppTheme.expense, symbol: "arrow.up.circle.fill")
                AnalyticsMetric(title: "Cash flow", amount: summary.cashFlow, color: summary.cashFlow >= 0 ? AppTheme.income : AppTheme.expense, symbol: "arrow.left.arrow.right.circle.fill")
                AnalyticsMetric(title: "Savings", amount: summary.savings, color: AppTheme.primary, symbol: "banknote.fill")
                AnalyticsMetric(title: "Investments", amount: summary.investments, color: .purple, symbol: "chart.line.uptrend.xyaxis")
            }
            Section("Where money went") {
                if summary.categorySpending.isEmpty { Text("Add categorised expenses to see a breakdown.").foregroundStyle(AppTheme.textSecondary) }
                ForEach(summary.categorySpending, id: \.category.id) { item in
                    HStack { Label(item.category.name, systemImage: item.category.iconName); Spacer(); Text(AnalyticsCurrency.string(item.amount)).font(.body.weight(.semibold).monospacedDigit()) }
                }
            }
        }
        .scrollContentBackground(.hidden).background(AppTheme.background).navigationTitle("Analytics")
    }
}

struct AnalyticsMetric: View {
    let title: String; let amount: Decimal; let color: Color; let symbol: String
    var body: some View {
        HStack(spacing: 12) { Image(systemName: symbol).foregroundStyle(color).frame(width: 30); Text(title); Spacer(); Text(AnalyticsCurrency.string(amount)).font(.body.weight(.semibold).monospacedDigit()).foregroundStyle(color) }
            .accessibilityElement(children: .combine)
    }
}

enum AnalyticsCurrency {
    static func string(_ amount: Decimal) -> String {
        let formatter = NumberFormatter(); formatter.numberStyle = .currency; formatter.currencyCode = UserDefaults.standard.string(forKey: "financeos.currencyCode") ?? "INR"; formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "₹0"
    }
}
