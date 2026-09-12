import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ContentUnavailableView("Your finance story starts here", systemImage: "chart.line.uptrend.xyaxis", description: Text("Create an account during onboarding to see your net worth."))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .navigationTitle("FinanceOS")
        }
    }
}
