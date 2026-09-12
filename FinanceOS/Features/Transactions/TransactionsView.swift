import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FinancialTransaction.date, order: .reverse) private var transactions: [FinancialTransaction]
    @StateObject private var viewModel = TransactionsViewModel()

    private var activeTransactions: [FinancialTransaction] { transactions.filter(\.isActive) }

    var body: some View {
        List {
            if activeTransactions.isEmpty {
                ContentUnavailableView("No transactions yet", systemImage: "arrow.left.arrow.right.circle", description: Text("Record an expense, income, or transfer to begin your financial timeline."))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(activeTransactions, id: \.id) { transaction in
                    TransactionRow(transaction: transaction)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                viewModel.delete(transaction, using: modelContext)
                            }
                        }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle("Transactions")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { viewModel.showsAddTransaction = true } label: { Image(systemName: "plus") }
                    .accessibilityLabel("Add transaction")
            }
        }
        .safeAreaInset(edge: .bottom) {
            FSPrimaryButton(title: "Add transaction") { viewModel.showsAddTransaction = true }
                .padding(.horizontal, 24).padding(.vertical, 12).background(.ultraThinMaterial)
        }
        .sheet(isPresented: $viewModel.showsAddTransaction) { AddTransactionView() }
        .alert("Something needs attention", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
    }
}

private struct TransactionRow: View {
    let transaction: FinancialTransaction

    private var color: Color {
        switch transaction.type {
        case .expense: AppTheme.expense
        case .income, .refund, .interest, .dividend: AppTheme.income
        case .savings, .transfer: AppTheme.primary
        case .investment: .purple
        case .loan: .orange
        case .adjustment: AppTheme.textSecondary
        }
    }

    private var accountName: String {
        transaction.destinationAccount?.name ?? transaction.sourceAccount?.name ?? "No account"
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: transaction.type.symbolName)
                .foregroundStyle(color).frame(width: 34, height: 34)
                .background(color.opacity(0.15), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.category?.name ?? transaction.type.displayName).font(.body.weight(.semibold))
                Text("\(accountName) · \(transaction.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption).foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            Text(signedAmount)
                .font(.body.weight(.semibold).monospacedDigit()).foregroundStyle(color)
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .combine)
    }

    private var signedAmount: String {
        let sign = transaction.type == .expense ? "−" : transaction.type.isIncome ? "+" : ""
        return sign + TransactionCurrency.string(transaction.amount, currencyCode: transaction.currencyCode)
    }
}

private struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("financeos.currencyCode") private var currencyCode = "INR"
    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.name) private var categories: [Category]
    @State private var type: TransactionType = .expense
    @State private var amountText = ""
    @State private var sourceAccountID: UUID?
    @State private var destinationAccountID: UUID?
    @State private var categoryID: UUID?
    @State private var date = Date.now
    @State private var notes = ""
    @State private var errorMessage: String?
    private let service = TransactionService()

    private var activeAccounts: [Account] { accounts.filter { !$0.isArchived } }
    private var sourceAccount: Account? { activeAccounts.first { $0.id == sourceAccountID } }
    private var destinationAccount: Account? { activeAccounts.first { $0.id == destinationAccountID } }
    private var category: Category? { categories.first { $0.id == categoryID } }
    private var needsSource: Bool { type == .expense || type.isMovement || type == .loan }
    private var needsDestination: Bool { type != .expense }

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Transaction type", selection: $type) {
                        ForEach(TransactionType.allCases) { type in Text(type.displayName).tag(type) }
                    }
                }
                Section("Amount") {
                    TextField("0", text: $amountText).keyboardType(.decimalPad)
                }
                if needsSource {
                    accountPicker("From account", selection: $sourceAccountID, accounts: allowedSourceAccounts)
                }
                if needsDestination {
                    accountPicker("To account", selection: $destinationAccountID, accounts: allowedDestinationAccounts)
                }
                if type == .expense {
                    Section("Category") {
                        Picker("Category", selection: $categoryID) {
                            Text("Choose category").tag(UUID?.none)
                            ForEach(categories.filter { !$0.isArchived }, id: \.id) { category in Text(category.name).tag(Optional(category.id)) }
                        }
                    }
                }
                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField("Note (optional)", text: $notes, axis: .vertical).lineLimit(2...4)
                }
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: dismiss.callAsFunction) }
                ToolbarItem(placement: .confirmationAction) { Button("Save", action: save).fontWeight(.semibold) }
            }
            .alert("Couldn’t save transaction", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private var allowedSourceAccounts: [Account] {
        type == .loan ? activeAccounts.filter { $0.type.isLiability } : activeAccounts
    }

    private var allowedDestinationAccounts: [Account] {
        switch type {
        case .savings, .investment: activeAccounts.filter { $0.type.isAsset }
        case .loan: activeAccounts.filter { $0.type.isAsset }
        default: activeAccounts
        }
    }

    private func accountPicker(_ title: String, selection: Binding<UUID?>, accounts: [Account]) -> some View {
        Section(title) {
            Picker(title, selection: selection) {
                Text("Choose account").tag(UUID?.none)
                ForEach(accounts, id: \.id) { account in Text(account.name).tag(Optional(account.id)) }
            }
        }
    }

    private func save() {
        let amount = Decimal(string: amountText) ?? 0
        do {
            try service.create(type: type, amount: amount, currencyCode: currencyCode, date: date, notes: notes, sourceAccount: sourceAccount, destinationAccount: destinationAccount, category: category, in: modelContext)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private enum TransactionCurrency {
    static func string(_ amount: Decimal, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "0"
    }
}
