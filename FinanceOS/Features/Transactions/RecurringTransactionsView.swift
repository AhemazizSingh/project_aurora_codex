import SwiftUI
import SwiftData

struct RecurringTransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecurringTransactionRule.nextDueDate) private var rules: [RecurringTransactionRule]
    @State private var message: String?
    private let service = RecurringTransactionService()

    var body: some View {
        List {
            if rules.isEmpty {
                ContentUnavailableView("No recurring transactions", systemImage: "repeat", description: Text("Recurring rules will appear here when scheduled transaction setup is added."))
                    .frame(maxWidth: .infinity, minHeight: 240).listRowBackground(Color.clear)
            } else {
                ForEach(rules, id: \.id) { rule in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(rule.type.displayName).font(.body.weight(.semibold))
                            Text("\(rule.frequency.displayName) · next \(rule.nextDueDate.formatted(date: .abbreviated, time: .omitted))").font(.caption).foregroundStyle(AppTheme.textSecondary)
                        }
                        Spacer()
                        Button("Run") { run(rule) }.buttonStyle(.bordered)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden).background(AppTheme.background).navigationTitle("Recurring")
        .alert("Recurring transactions", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) { Button("OK", role: .cancel) { message = nil } } message: { Text(message ?? "") }
    }

    private func run(_ rule: RecurringTransactionRule) {
        do { let count = try service.generateDueTransactions(for: rule, in: modelContext); message = count == 0 ? "Nothing is due yet." : "Added \(count) due transaction\(count == 1 ? "" : "s")." }
        catch { message = error.localizedDescription }
    }
}
