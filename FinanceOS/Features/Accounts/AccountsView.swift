import SwiftUI
import SwiftData

struct AccountsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Account.createdAt) private var accounts: [Account]
    @StateObject private var viewModel = AccountsViewModel()

    private var visibleAccounts: [Account] {
        accounts.filter { viewModel.showsArchivedAccounts || !$0.isArchived }
    }

    private var assets: Decimal {
        visibleAccounts.filter { $0.type.isAsset }.reduce(0) { $0 + $1.currentBalance }
    }

    private var liabilities: Decimal {
        visibleAccounts.filter { $0.type.isLiability }.reduce(0) { $0 + $1.currentBalance }
    }

    private var netWorth: Decimal { assets - liabilities }

    var body: some View {
        List {
            Section {
                netWorthCard
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            if visibleAccounts.isEmpty {
                Section {
                    ContentUnavailableView("No accounts yet", systemImage: "building.columns", description: Text("Add an account to track where your money is."))
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: 220)
                        .listRowBackground(Color.clear)
                }
            } else {
                Section(viewModel.showsArchivedAccounts ? "All Accounts" : "Active Accounts") {
                    ForEach(visibleAccounts, id: \.id) { account in
                        AccountRow(account: account, hidesBalances: viewModel.hidesBalances)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if !account.isArchived {
                                    Button("Archive", systemImage: "archivebox", role: .destructive) {
                                        viewModel.archive(account, using: modelContext)
                                    }
                                }
                            }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(viewModel.hidesBalances ? "Show balances" : "Hide balances") {
                    viewModel.hidesBalances.toggle()
                }
                .accessibilityLabel(viewModel.hidesBalances ? "Show balances" : "Hide balances")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Toggle("Show archived", isOn: $viewModel.showsArchivedAccounts)
                } label: { Image(systemName: "line.3.horizontal.decrease.circle") }
            }
        }
        .safeAreaInset(edge: .bottom) {
            FSPrimaryButton(title: "Add account") { viewModel.showsAddAccount = true }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $viewModel.showsAddAccount) { AddAccountView() }
        .alert("Something needs attention", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
    }

    private var netWorthCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Net Worth").font(.subheadline.weight(.medium)).foregroundStyle(AppTheme.textSecondary)
            Text(viewModel.hidesBalances ? "••••••" : CurrencyDisplay.string(netWorth))
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .monospacedDigit()
            HStack {
                metric("Assets", assets, color: AppTheme.income)
                Spacer()
                metric("Liabilities", liabilities, color: AppTheme.expense)
            }
        }
        .padding(20)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func metric(_ title: String, _ amount: Decimal, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(AppTheme.textSecondary)
            Text(viewModel.hidesBalances ? "••••" : CurrencyDisplay.string(amount))
                .font(.headline.monospacedDigit()).foregroundStyle(color)
        }
    }
}

private struct AccountRow: View {
    let account: Account
    let hidesBalances: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: account.type.symbolName)
                .font(.title3)
                .foregroundStyle(account.type.isLiability ? AppTheme.expense : AppTheme.primary)
                .frame(width: 32, height: 32)
                .background(AppTheme.surface, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(account.name).font(.body.weight(.semibold))
                Text(account.type.displayName + (account.isArchived ? " · Archived" : ""))
                    .font(.caption).foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            Text(hidesBalances ? "••••" : CurrencyDisplay.string(account.currentBalance))
                .font(.body.weight(.semibold).monospacedDigit())
                .foregroundStyle(account.type.isLiability ? AppTheme.expense : AppTheme.textPrimary)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

private struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("financeos.currencyCode") private var currencyCode = "INR"
    @State private var name = ""
    @State private var type: AccountType = .bank
    @State private var openingBalance = ""
    @State private var errorMessage: String?
    private let service = AccountService()

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    TextField("Name", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(AccountType.allCases) { accountType in
                            Label(accountType.displayName, systemImage: accountType.symbolName).tag(accountType)
                        }
                    }
                }
                Section("Opening balance") {
                    TextField("0", text: $openingBalance)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: dismiss.callAsFunction) }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.fontWeight(.semibold)
                }
            }
            .alert("Couldn’t save account", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func save() {
        let balance = Decimal(string: openingBalance) ?? 0
        do {
            try service.create(name: name, type: type, currencyCode: currencyCode, openingBalance: balance, in: modelContext)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private enum CurrencyDisplay {
    static func string(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = UserDefaults.standard.string(forKey: "financeos.currencyCode") ?? "INR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "₹0"
    }
}
