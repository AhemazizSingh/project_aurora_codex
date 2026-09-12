import SwiftUI

/// The five primary destinations specified in the FinanceOS PRD.
struct AppTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var showsQuickAdd = false
    @State private var quickType: TransactionType?

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)
            NavigationStack { TransactionsView() }
                .tabItem { Label("Transactions", systemImage: "arrow.left.arrow.right") }
                .tag(Tab.transactions)
            NavigationStack { AnalyticsView() }
                .tabItem { Label("Analytics", systemImage: "chart.bar") }
                .tag(Tab.analytics)
            NavigationStack { GoalsView() }
                .tabItem { Label("Goals", systemImage: "target") }
                .tag(Tab.goals)
            NavigationStack { SettingsView() }
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        .tint(AppTheme.primary)
        .overlay(alignment: .bottom) {
            Button { showsQuickAdd = true } label: {
                Image(systemName: "plus").font(.title2.weight(.bold)).foregroundStyle(.white).frame(width: 56, height: 56).background(AppTheme.primary, in: Circle()).shadow(radius: 8, y: 4)
            }
            .accessibilityLabel("Add transaction")
            .padding(.bottom, 48)
        }
        .sheet(isPresented: $showsQuickAdd) { QuickAddView { type in quickType = type } }
        .sheet(item: $quickType) { type in AddTransactionView(initialType: type) }
    }

    fileprivate enum Tab: Hashable { case home, transactions, analytics, goals, settings }
}

private struct QuickAddView: View {
    @Environment(\.dismiss) private var dismiss
    let select: (TransactionType) -> Void
    var body: some View {
        NavigationStack {
            List {
                ForEach([TransactionType.expense, .income, .savings, .investment, .transfer], id: \.self) { type in
                    Button { select(type); dismiss() } label: { Label(type.displayName, systemImage: type.symbolName) }
                }
            }
            .navigationTitle("Quick Add")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close", action: dismiss.callAsFunction) } }
        }
    }
}
