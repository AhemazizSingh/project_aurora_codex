import SwiftUI

struct SettingsView: View {
    @AppStorage("financeos.userName") private var userName = ""
    @AppStorage("financeos.currencyCode") private var currencyCode = "INR"
    @AppStorage("financeos.themeMode") private var themeModeRawValue = AppThemeMode.system.rawValue
    @AppStorage("financeos.privacyMode") private var privacyMode = false
    @AppStorage("financeos.deviceLockEnabled") private var deviceLockEnabled = false
    @AppStorage("financeos.autoLockSeconds") private var autoLockSeconds = 60
    @AppStorage("financeos.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showsResetConfirmation = false

    private var themeBinding: Binding<AppThemeMode> {
        Binding(get: { AppThemeMode(rawValue: themeModeRawValue) ?? .system }, set: { themeModeRawValue = $0.rawValue })
    }

    var body: some View {
        Form {
            Section("Profile") { TextField("Name", text: $userName) }
            Section("Preferences") {
                Picker("Appearance", selection: themeBinding) { ForEach(AppThemeMode.allCases) { Text($0.title).tag($0) } }
                Picker("Currency", selection: $currencyCode) {
                    Text("Indian Rupee (₹)").tag("INR"); Text("US Dollar ($)").tag("USD"); Text("Euro (€)").tag("EUR"); Text("British Pound (£)").tag("GBP")
                }
            }
            Section("Privacy") {
                Toggle("Privacy mode", isOn: $privacyMode)
                Text("Hides financial amounts across overview screens when you need discretion.").font(.footnote).foregroundStyle(AppTheme.textSecondary)
            }
            Section("Security") {
                Toggle("Require device unlock", isOn: $deviceLockEnabled)
                if deviceLockEnabled {
                    Picker("Auto-lock", selection: $autoLockSeconds) {
                        Text("Immediately").tag(0); Text("30 seconds").tag(30); Text("1 minute").tag(60); Text("5 minutes").tag(300); Text("10 minutes").tag(600)
                    }
                }
                Text("Uses Face ID, Touch ID, or your device passcode. FinanceOS does not receive or store biometric data.").font(.footnote).foregroundStyle(AppTheme.textSecondary)
            }
            Section("Data") {
                NavigationLink { TransactionsView() } label: { Label("Transactions", systemImage: "arrow.left.arrow.right.circle") }
                NavigationLink { AccountsView() } label: { Label("Accounts", systemImage: "building.columns") }
                NavigationLink { BudgetsView() } label: { Label("Budgets", systemImage: "chart.pie") }
                NavigationLink { GoalsView() } label: { Label("Goals", systemImage: "target") }
                NavigationLink { ExportView() } label: { Label("Export", systemImage: "square.and.arrow.up") }
                NavigationLink { ImportView() } label: { Label("Import CSV", systemImage: "square.and.arrow.down") }
                NavigationLink { RecurringTransactionsView() } label: { Label("Recurring transactions", systemImage: "repeat") }
            }
            Section("Development") {
                Button("Restart onboarding") { showsResetConfirmation = true }.foregroundStyle(AppTheme.expense)
                Text("This only returns to onboarding. It never deletes financial data.").font(.footnote).foregroundStyle(AppTheme.textSecondary)
            }
            Section("About") { LabeledContent("App", value: "FinanceOS"); LabeledContent("Data", value: "Stored locally"); LabeledContent("Version", value: "0.1 Foundation") }
        }
        .navigationTitle("Settings")
        .alert("Restart onboarding?", isPresented: $showsResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Restart", role: .destructive) { hasCompletedOnboarding = false }
        } message: { Text("Your existing accounts and transactions will remain saved.") }
    }
}
