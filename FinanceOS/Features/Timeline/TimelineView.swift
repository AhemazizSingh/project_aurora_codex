import SwiftUI
import SwiftData

struct TimelineView: View {
    @Query(sort: \FinancialTransaction.date, order: .reverse) private var transactions: [FinancialTransaction]
    @Query(sort: \Goal.createdAt, order: .reverse) private var goals: [Goal]

    private var entries: [TimelineEntry] { TimelineService.entries(transactions: transactions, goals: goals) }

    var body: some View {
        List {
            if entries.isEmpty {
                ContentUnavailableView("Your timeline is waiting", systemImage: "clock.arrow.circlepath", description: Text("Transactions and goal milestones will form your financial story here."))
                    .frame(maxWidth: .infinity, minHeight: 280).listRowBackground(Color.clear)
            } else {
                ForEach(entries) { entry in
                    HStack(alignment: .top, spacing: 14) {
                        VStack(spacing: 0) {
                            Image(systemName: entry.symbolName).foregroundStyle(color(for: entry.kind)).frame(width: 30, height: 30).background(color(for: entry.kind).opacity(0.15), in: Circle())
                            Rectangle().fill(AppTheme.textSecondary.opacity(0.25)).frame(width: 1).frame(maxHeight: .infinity)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.title).font(.body.weight(.semibold))
                            Text(entry.detail).font(.caption).foregroundStyle(AppTheme.textSecondary)
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened)).font(.caption2).foregroundStyle(AppTheme.textSecondary)
                        }.padding(.bottom, 14)
                    }.accessibilityElement(children: .combine)
                }
            }
        }
        .scrollContentBackground(.hidden).background(AppTheme.background).navigationTitle("Timeline")
    }

    private func color(for kind: TimelineEntry.Kind) -> Color {
        switch kind { case .transaction: AppTheme.primary; case .goalCreated: .orange; case .goalCompleted: AppTheme.income }
    }
}
