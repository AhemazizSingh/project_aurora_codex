import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Goal.deadline) private var goals: [Goal]
    @State private var showsAddGoal = false
    @State private var errorMessage: String?
    private let service = GoalService()

    var body: some View {
        List {
            if goals.filter({ $0.status == .active }).isEmpty {
                ContentUnavailableView("No active goals", systemImage: "target", description: Text("Set a goal and give your savings a clear purpose."))
                    .frame(maxWidth: .infinity, minHeight: 280).listRowBackground(Color.clear)
            } else {
                ForEach(goals.filter { $0.status == .active }, id: \.id) { goal in
                    NavigationLink { GoalDetailView(goal: goal) } label: { GoalRow(goal: goal) }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Archive", systemImage: "archivebox", role: .destructive) { archive(goal) }
                        }
                }
            }
        }
        .scrollContentBackground(.hidden).background(AppTheme.background)
        .navigationTitle("Goals")
        .safeAreaInset(edge: .bottom) {
            FSPrimaryButton(title: "Create goal") { showsAddGoal = true }
                .padding(.horizontal, 24).padding(.vertical, 12).background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showsAddGoal) { AddGoalView() }
        .alert("Couldn’t update goal", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private func archive(_ goal: Goal) {
        do { try service.archive(goal, in: modelContext) }
        catch { errorMessage = "This goal could not be archived. Please try again." }
    }
}

private struct GoalRow: View {
    let goal: Goal

    var body: some View {
        HStack(spacing: 16) {
            GoalProgressRing(progress: goal.progress)
                .frame(width: 52, height: 52)
                .overlay(Text("\(Int((goal.progress as NSDecimalNumber).doubleValue * 100))%").font(.caption2.weight(.bold)).monospacedDigit())
            VStack(alignment: .leading, spacing: 5) {
                Text(goal.title).font(.body.weight(.semibold))
                Text("\(GoalCurrency.string(goal.savedAmount)) of \(GoalCurrency.string(goal.targetAmount))")
                    .font(.caption).foregroundStyle(AppTheme.textSecondary)
                Text("Due \(goal.deadline.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2).foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(.vertical, 7)
        .accessibilityElement(children: .combine)
    }
}

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("financeos.currencyCode") private var currencyCode = "INR"
    let goal: Goal
    @State private var showsContribution = false
    @State private var errorMessage: String?
    private let service = GoalService()

    private var monthsRemaining: Int {
        max(Calendar.current.dateComponents([.month], from: .now, to: goal.deadline).month ?? 0, 1)
    }

    private var monthlyRequirement: Decimal { goal.remainingAmount / Decimal(monthsRemaining) }

    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    GoalProgressRing(progress: goal.progress).frame(width: 160, height: 160)
                        .overlay(Text("\(Int((goal.progress as NSDecimalNumber).doubleValue * 100))%").font(.title.bold()).monospacedDigit())
                    Text(goal.title).font(.title2.bold())
                    Text("\(GoalCurrency.string(goal.savedAmount)) saved of \(GoalCurrency.string(goal.targetAmount))")
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 16).listRowBackground(Color.clear)
            }
            Section("Plan") {
                LabeledContent("Remaining", value: GoalCurrency.string(goal.remainingAmount))
                LabeledContent("Target date", value: goal.deadline.formatted(date: .long, time: .omitted))
                LabeledContent("Suggested monthly saving", value: GoalCurrency.string(monthlyRequirement))
                LabeledContent("Savings account", value: goal.linkedAccount?.name ?? "Not set")
            }
            if !goal.notes.isEmpty { Section("Notes") { Text(goal.notes) } }
        }
        .scrollContentBackground(.hidden).background(AppTheme.background)
        .navigationTitle("Goal")
        .safeAreaInset(edge: .bottom) {
            if goal.status == .active {
                FSPrimaryButton(title: "Contribute") { showsContribution = true }
                    .padding(.horizontal, 24).padding(.vertical, 12).background(.ultraThinMaterial)
            }
        }
        .sheet(isPresented: $showsContribution) { GoalContributionView(goal: goal) }
        .alert("Couldn’t update goal", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }
}

private struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Account.name) private var accounts: [Account]
    @State private var title = ""
    @State private var targetText = ""
    @State private var deadline = Calendar.current.date(byAdding: .month, value: 12, to: .now) ?? .now
    @State private var priority: GoalPriority = .medium
    @State private var linkedAccountID: UUID?
    @State private var notes = ""
    @State private var errorMessage: String?
    private let service = GoalService()

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    TextField("Title", text: $title)
                    TextField("Target amount", text: $targetText).keyboardType(.decimalPad)
                    DatePicker("Target date", selection: $deadline, in: Date.now... , displayedComponents: .date)
                    Picker("Priority", selection: $priority) { ForEach(GoalPriority.allCases) { Text($0.displayName).tag($0) } }
                }
                Section("Savings account") {
                    Picker("Account", selection: $linkedAccountID) {
                        Text("Choose account").tag(UUID?.none)
                        ForEach(accounts.filter { !$0.isArchived && $0.type.isAsset }, id: \.id) { account in Text(account.name).tag(Optional(account.id)) }
                    }
                }
                Section("Notes") { TextField("Optional", text: $notes, axis: .vertical).lineLimit(2...4) }
            }
            .navigationTitle("New Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: dismiss.callAsFunction) }
                ToolbarItem(placement: .confirmationAction) { Button("Save", action: save).fontWeight(.semibold) }
            }
            .alert("Couldn’t create goal", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func save() {
        let target = Decimal(string: targetText) ?? 0
        let account = accounts.first { $0.id == linkedAccountID }
        do { try service.create(title: title, targetAmount: target, deadline: deadline, priority: priority, linkedAccount: account, notes: notes, in: modelContext); dismiss() }
        catch { errorMessage = error.localizedDescription }
    }
}

private struct GoalContributionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("financeos.currencyCode") private var currencyCode = "INR"
    @Query(sort: \Account.name) private var accounts: [Account]
    let goal: Goal
    @State private var sourceAccountID: UUID?
    @State private var amountText = ""
    @State private var errorMessage: String?
    private let service = GoalService()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Amount", text: $amountText).keyboardType(.decimalPad)
                Picker("From account", selection: $sourceAccountID) {
                    Text("Choose account").tag(UUID?.none)
                    ForEach(accounts.filter { !$0.isArchived && $0.type.isAsset && $0.id != goal.linkedAccount?.id }, id: \.id) { Text($0.name).tag(Optional($0.id)) }
                }
            }
            .navigationTitle("Contribute to \(goal.title)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: dismiss.callAsFunction) }
                ToolbarItem(placement: .confirmationAction) { Button("Save", action: save).fontWeight(.semibold) }
            }
            .alert("Couldn’t save contribution", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func save() {
        do {
            try service.contribute(amount: Decimal(string: amountText) ?? 0, from: accounts.first { $0.id == sourceAccountID }, to: goal, currencyCode: currencyCode, in: modelContext)
            dismiss()
        } catch { errorMessage = error.localizedDescription }
    }
}

private struct GoalProgressRing: View {
    let progress: Decimal
    var body: some View {
        ZStack {
            Circle().stroke(AppTheme.primary.opacity(0.18), lineWidth: 10)
            Circle().trim(from: 0, to: CGFloat((progress as NSDecimalNumber).doubleValue)).stroke(AppTheme.primary, style: StrokeStyle(lineWidth: 10, lineCap: .round)).rotationEffect(.degrees(-90))
        }
    }
}

private enum GoalCurrency {
    static func string(_ amount: Decimal) -> String {
        let formatter = NumberFormatter(); formatter.numberStyle = .currency
        formatter.currencyCode = UserDefaults.standard.string(forKey: "financeos.currencyCode") ?? "INR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "₹0"
    }
}
