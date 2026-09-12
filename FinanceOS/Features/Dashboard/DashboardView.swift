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
