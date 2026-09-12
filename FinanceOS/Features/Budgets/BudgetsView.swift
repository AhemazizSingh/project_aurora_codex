import SwiftUI
import SwiftData

struct BudgetsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Budget.createdAt, order: .reverse) private var budgets: [Budget]
    @Query(sort: \FinancialTransaction.date, order: .reverse) private var transactions: [FinancialTransaction]
    @State private var showsAddBudget = false
    @State private var errorMessage: String?
    private let service = BudgetService()

    private var activeBudgets: [Budget] { budgets.filter { !$0.isArchived } }

    var body: some View {
        List {
            if activeBudgets.isEmpty {
                ContentUnavailableView("No budgets yet", systemImage: "chart.pie", description: Text("Set a category limit to stay intentional with your spending."))
                    .frame(maxWidth: .infinity, minHeight: 280).listRowBackground(Color.clear)
            } else {
                ForEach(activeBudgets, id: \.id) { budget in
                    BudgetRow(budget: budget, spent: BudgetEngine.spent(for: budget, transactions: transactions))
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Archive", systemImage: "archivebox", role: .destructive) { archive(budget) }
                        }
                }
            }
        }
        .scrollContentBackground(.hidden).background(AppTheme.background)
        .navigationTitle("Budgets")
        .safeAreaInset(edge: .bottom) {
            FSPrimaryButton(title: "Create budget") { showsAddBudget = true }
                .padding(.horizontal, 24).padding(.vertical, 12).background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showsAddBudget) { AddBudgetView() }
        .alert("Couldn’t update budget", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private func archive(_ budget: Budget) {
        do { try service.archive(budget, in: modelContext) }
        catch { errorMessage = "This budget could not be archived. Please try again." }
    }
}

private struct BudgetRow: View {
    let budget: Budget
    let spent: Decimal

    private var progress: Decimal { min(max(spent / budget.amount, 0), 1) }
    private var statusColor: Color {
        let ratio = ((spent / budget.amount) as NSDecimalNumber).doubleValue
        if ratio >= 1 { return AppTheme.expense }
        if ratio >= 0.9 { return .orange }
        if ratio >= 0.75 { return .yellow }
        return AppTheme.income
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(budget.name).font(.body.weight(.semibold))
                    Text("\(budget.category?.name ?? "Category") · \(budget.period.displayName)")
                        .font(.caption).foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
                Text("\(Int((progress as NSDecimalNumber).doubleValue * 100))%")
                    .font(.headline.monospacedDigit()).foregroundStyle(statusColor)
            }
            ProgressView(value: (progress as NSDecimalNumber).doubleValue)
                .tint(statusColor)
            HStack {
                Text("\(BudgetCurrency.string(spent)) spent").font(.caption).foregroundStyle(AppTheme.textSecondary)
                Spacer()
                Text("\(BudgetCurrency.string(max(budget.amount - spent, 0))) left").font(.caption.weight(.medium)).foregroundStyle(statusColor)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

private struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.name) private var categories: [Category]
    @State private var name = ""
    @State private var amountText = ""
    @State private var period: BudgetPeriod = .monthly
    @State private var categoryID: UUID?
    @State private var customStart = Date.now
    @State private var customEnd = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
    @State private var errorMessage: String?
    private let service = BudgetService()

    var body: some View {
        NavigationStack {
            Form {
                Section("Budget") {
                    TextField("Name", text: $name)
                    TextField("Amount", text: $amountText).keyboardType(.decimalPad)
                    Picker("Period", selection: $period) { ForEach(BudgetPeriod.allCases) { Text($0.displayName).tag($0) } }
                    Picker("Category", selection: $categoryID) {
                        Text("Choose category").tag(UUID?.none)
                        ForEach(categories.filter { !$0.isArchived }, id: \.id) { Text($0.name).tag(Optional($0.id)) }
                    }
                }
                if period == .custom {
                    Section("Custom period") {
                        DatePicker("Start", selection: $customStart, displayedComponents: .date)
                        DatePicker("End", selection: $customEnd, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Budget")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: dismiss.callAsFunction) }
                ToolbarItem(placement: .confirmationAction) { Button("Save", action: save).fontWeight(.semibold) }
            }
            .alert("Couldn’t create budget", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func save() {
        let category = categories.first { $0.id == categoryID }
        do {
            try service.create(name: name, amount: Decimal(string: amountText) ?? 0, period: period, category: category, customStartDate: period == .custom ? customStart : nil, customEndDate: period == .custom ? customEnd : nil, in: modelContext)
            dismiss()
        } catch { errorMessage = error.localizedDescription }
    }
}

private enum BudgetCurrency {
    static func string(_ amount: Decimal) -> String {
        let formatter = NumberFormatter(); formatter.numberStyle = .currency; formatter.currencyCode = UserDefaults.standard.string(forKey: "financeos.currencyCode") ?? "INR"; formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "₹0"
    }
}
