import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FinancialTransaction.date, order: .reverse) private var transactions: [FinancialTransaction]
    @StateObject private var viewModel = TransactionsViewModel()

    private var activeTransactions: [FinancialTransaction] { viewModel.filter.apply(to: transactions) }

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
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button("Edit", systemImage: "pencil") { viewModel.editingTransaction = transaction }
                                .tint(AppTheme.primary)
                        }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle("Transactions")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { viewModel.showsFilters = true } label: { Image(systemName: "line.3.horizontal.decrease.circle") }
                    .accessibilityLabel("Filter and sort transactions")
            }
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
        .sheet(isPresented: $viewModel.showsFilters) { TransactionFilterView(filter: $viewModel.filter) }
        .sheet(item: $viewModel.editingTransaction) { transaction in AddTransactionView(transaction: transaction) }
        .alert("Something needs attention", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
        .overlay(alignment: .bottom) {
            if viewModel.undoableTransaction != nil {
                HStack {
                    Text("Transaction deleted")
                    Spacer()
                    Button("Undo") { viewModel.undoDelete(using: modelContext) }.fontWeight(.bold)
                }
                .padding().background(AppTheme.surface, in: Capsule()).shadow(radius: 8)
                .padding(.bottom, 92).padding(.horizontal, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .task(id: viewModel.undoableTransaction?.id) {
                    try? await Task.sleep(for: .seconds(10))
                    viewModel.undoableTransaction = nil
                }
            }
        }
    }
}

private struct TransactionFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.name) private var categories: [Category]
    @Binding var filter: TransactionFilter

    var body: some View {
        NavigationStack {
            Form {
                Section("Filter") {
                    Picker("Type", selection: $filter.type) {
                        Text("All types").tag(TransactionType?.none)
                        ForEach(TransactionType.allCases) { Text($0.displayName).tag(Optional($0)) }
                    }
                    Picker("Account", selection: $filter.accountID) {
                        Text("All accounts").tag(UUID?.none)
                        ForEach(accounts.filter { !$0.isArchived }, id: \.id) { Text($0.name).tag(Optional($0.id)) }
                    }
                    Picker("Category", selection: $filter.categoryID) {
                        Text("All categories").tag(UUID?.none)
                        ForEach(categories.filter { !$0.isArchived }, id: \.id) { Text($0.name).tag(Optional($0.id)) }
                    }
                }
                Section("Sort") {
                    Picker("Order", selection: $filter.sortOrder) { ForEach(TransactionSortOrder.allCases) { Text($0.displayName).tag($0) } }
                }
            }
            .navigationTitle("Filter Transactions")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Reset") { filter = TransactionFilter() } }
                ToolbarItem(placement: .confirmationAction) { Button("Done", action: dismiss.callAsFunction).fontWeight(.semibold) }
            }
        }
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
                if !transaction.labels.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(transaction.labels, id: \.id) { label in
                                Text(label.name)
                                    .font(.caption2.weight(.medium))
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(AppTheme.primary.opacity(0.15), in: Capsule())
                            }
                        }
                    }
                }
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

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("financeos.currencyCode") private var currencyCode = "INR"
    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \TransactionLabel.name) private var labels: [TransactionLabel]
    @State private var type: TransactionType
    @State private var amountText = ""
    @State private var sourceAccountID: UUID?
    @State private var destinationAccountID: UUID?
    @State private var categoryID: UUID?
    @State private var selectedLabelIDs = Set<UUID>()
    @State private var date = Date.now
    @State private var notes = ""
    @State private var errorMessage: String?
    private let service = TransactionService()
    private let existingTransaction: FinancialTransaction?

    init(initialType: TransactionType = .expense) {
        existingTransaction = nil
        _type = State(initialValue: initialType)
    }

    init(transaction: FinancialTransaction) {
        existingTransaction = transaction
        _type = State(initialValue: transaction.type)
        _amountText = State(initialValue: transaction.amount.description)
        _sourceAccountID = State(initialValue: transaction.sourceAccount?.id)
        _destinationAccountID = State(initialValue: transaction.destinationAccount?.id)
        _categoryID = State(initialValue: transaction.category?.id)
        _selectedLabelIDs = State(initialValue: Set(transaction.labels.map(\.id)))
        _date = State(initialValue: transaction.date)
        _notes = State(initialValue: transaction.notes)
    }

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
                if type == .expense || type == .refund {
                    Section("Category") {
                        Picker("Category", selection: $categoryID) {
                            Text("Choose category").tag(UUID?.none)
                            ForEach(categories.filter { !$0.isArchived }, id: \.id) { category in Text(category.name).tag(Optional(category.id)) }
                        }
                    }
                }
                if !labels.filter({ !$0.isArchived }).isEmpty {
                    Section("Labels") {
                        ForEach(labels.filter { !$0.isArchived }, id: \.id) { label in
                            Toggle(label.name, isOn: Binding(
                                get: { selectedLabelIDs.contains(label.id) },
                                set: { isSelected in
                                    if isSelected { selectedLabelIDs.insert(label.id) }
                                    else { selectedLabelIDs.remove(label.id) }
                                }
                            ))
                        }
                    }
                }
                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField("Note (optional)", text: $notes, axis: .vertical).lineLimit(2...4)
                }
            }
            .navigationTitle(existingTransaction == nil ? "Add Transaction" : "Edit Transaction")
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
            let selectedLabels = labels.filter { selectedLabelIDs.contains($0.id) }
            if let existingTransaction {
                try service.update(existingTransaction, type: type, amount: amount, currencyCode: currencyCode, date: date, notes: notes, sourceAccount: sourceAccount, destinationAccount: destinationAccount, category: category, labels: selectedLabels, in: modelContext)
            } else {
                try service.create(type: type, amount: amount, currencyCode: currencyCode, date: date, notes: notes, sourceAccount: sourceAccount, destinationAccount: destinationAccount, category: category, labels: selectedLabels, in: modelContext)
            }
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
