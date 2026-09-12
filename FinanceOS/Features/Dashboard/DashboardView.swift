import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ContentUnavailableView("Your finance story starts here", systemImage: "chart.line.uptrend.xyaxis", description: Text("Add transactions to see your complete financial picture."))
                    .foregroundStyle(AppTheme.textPrimary)
            }
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
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { AccountsView() } label: {
                        Image(systemName: "building.columns")
                    }
                    .accessibilityLabel("Accounts")
                }
            }
        }
    }
}
