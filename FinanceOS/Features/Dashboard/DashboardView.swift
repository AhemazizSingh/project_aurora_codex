import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var accounts: [Account]
    @Query(sort: \FinancialTransaction.date, order: .reverse) private var transactions: [FinancialTransaction]
    @Query(sort: \Budget.createdAt, order: .reverse) private var budgets: [Budget]
    @Query(sort: \Goal.deadline) private var goals: [Goal]

    private var insights: [FinancialInsight] { InsightEngine.generate(budgets: budgets, goals: goals, transactions: transactions) }

    private var summary: FinancialSummary { AnalyticsService.summary(accounts: accounts, transactions: transactions, range: Calendar.current.dateInterval(of: .month, for: .now)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    hero
                    Text("This month").font(.title3.bold()).padding(.horizontal, 24)
                    summaryGrid.padding(.horizontal, 24)
                    if let budget = budgets.first(where: { !$0.isArchived }) { budgetCard(budget).padding(.horizontal, 24) }
                    if let goal = goals.first(where: { $0.status == .active }) { goalCard(goal).padding(.horizontal, 24) }
                    if let insight = insights.first {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Insight").font(.title3.bold())
                            InsightCard(insight: insight)
                        }.padding(.horizontal, 24)
                    }
                    recentTransactions
                }.padding(.vertical, 12)
            }
            .background(AppTheme.background)
            .navigationTitle("FinanceOS")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 16) {
                        NavigationLink { TransactionsView() } label: { Image(systemName: "arrow.left.arrow.right.circle") }
                            .accessibilityLabel("Transactions")
                        NavigationLink { CategoriesView() } label: { Image(systemName: "square.grid.2x2") }
                            .accessibilityLabel("Categories")
                        NavigationLink { LabelsView() } label: { Image(systemName: "tag") }
                            .accessibilityLabel("Labels")
                        NavigationLink { GoalsView() } label: { Image(systemName: "target") }
                            .accessibilityLabel("Goals")
                        NavigationLink { BudgetsView() } label: { Image(systemName: "chart.pie") }
                            .accessibilityLabel("Budgets")
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink { SearchView() } label: { Image(systemName: "magnifyingglass") }.accessibilityLabel("Search")
                    NavigationLink { AnalyticsView() } label: { Image(systemName: "chart.bar.xaxis") }.accessibilityLabel("Analytics")
                    NavigationLink { AccountsView() } label: { Image(systemName: "building.columns") }.accessibilityLabel("Accounts")
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Net Worth").font(.subheadline.weight(.medium)).foregroundStyle(AppTheme.textSecondary)
            Text(AnalyticsCurrency.string(AnalyticsService.summary(accounts: accounts, transactions: transactions).netWorth)).font(.system(size: 38, weight: .bold, design: .rounded)).monospacedDigit()
            Text("Your assets minus liabilities").font(.caption).foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(24).background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 28, style: .continuous)).padding(.horizontal, 24)
        .accessibilityElement(children: .combine)
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            DashboardMetric(title: "Income", amount: summary.income, color: AppTheme.income, icon: "arrow.down.circle.fill")
            DashboardMetric(title: "Expenses", amount: summary.expenses, color: AppTheme.expense, icon: "arrow.up.circle.fill")
            DashboardMetric(title: "Savings", amount: summary.savings, color: AppTheme.primary, icon: "banknote.fill")
            DashboardMetric(title: "Investments", amount: summary.investments, color: .purple, icon: "chart.line.uptrend.xyaxis")
        }
    }

    private func budgetCard(_ budget: Budget) -> some View {
        let spent = BudgetEngine.spent(for: budget, transactions: transactions)
        return NavigationLink { BudgetsView() } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack { Label("Budget", systemImage: "chart.pie"); Spacer(); Text(budget.name).foregroundStyle(AppTheme.textSecondary) }
                ProgressView(value: min(((spent / budget.amount) as NSDecimalNumber).doubleValue, 1)).tint(AppTheme.primary)
                Text("\(AnalyticsCurrency.string(spent)) of \(AnalyticsCurrency.string(budget.amount)) spent").font(.caption).foregroundStyle(AppTheme.textSecondary)
            }.padding(18).background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        }.buttonStyle(.plain)
    }

    private func goalCard(_ goal: Goal) -> some View {
        NavigationLink { GoalsView() } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack { Label("Goal", systemImage: "target"); Spacer(); Text(goal.title).foregroundStyle(AppTheme.textSecondary) }
                ProgressView(value: (goal.progress as NSDecimalNumber).doubleValue).tint(AppTheme.primary)
                Text("\(AnalyticsCurrency.string(goal.savedAmount)) of \(AnalyticsCurrency.string(goal.targetAmount)) saved").font(.caption).foregroundStyle(AppTheme.textSecondary)
            }.padding(18).background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        }.buttonStyle(.plain)
    }

    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { Text("Recent transactions").font(.title3.bold()); Spacer(); NavigationLink("See all") { TransactionsView() }.font(.subheadline.weight(.semibold)) }
            if transactions.filter(\.isActive).isEmpty { Text("No transactions yet.").foregroundStyle(AppTheme.textSecondary) }
            else { ForEach(transactions.filter(\.isActive).prefix(5), id: \.id) { item in HStack { Text(item.category?.name ?? item.type.displayName); Spacer(); Text(AnalyticsCurrency.string(item.amount)).monospacedDigit() }.font(.subheadline) } }
        }.padding(.horizontal, 24)
    }
}

private struct DashboardMetric: View {
    let title: String; let amount: Decimal; let color: Color; let icon: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { Image(systemName: icon).foregroundStyle(color); Text(title).font(.caption).foregroundStyle(AppTheme.textSecondary); Text(AnalyticsCurrency.string(amount)).font(.headline.monospacedDigit()).foregroundStyle(color) }
            .frame(maxWidth: .infinity, alignment: .leading).padding(16).background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)).accessibilityElement(children: .combine)
    }
}
