import Foundation

struct TimelineEntry: Identifiable {
    enum Kind: Equatable { case transaction, goalCreated, goalCompleted }
    let id: String
    let date: Date
    let kind: Kind
    let title: String
    let detail: String
    let symbolName: String
}

enum TimelineService {
    static func entries(transactions: [FinancialTransaction], goals: [Goal]) -> [TimelineEntry] {
        let transactionEntries = transactions.filter(\.isActive).map { item in
            TimelineEntry(id: "transaction-\(item.id)", date: item.date, kind: .transaction, title: item.category?.name ?? item.type.displayName, detail: AnalyticsCurrency.string(item.amount), symbolName: item.type.symbolName)
        }
        let goalEntries = goals.flatMap { goal -> [TimelineEntry] in
            var entries = [TimelineEntry(id: "goal-created-\(goal.id)", date: goal.createdAt, kind: .goalCreated, title: "Created \(goal.title)", detail: "Goal target: \(AnalyticsCurrency.string(goal.targetAmount))", symbolName: "target")]
            if goal.status == .completed {
                entries.append(TimelineEntry(id: "goal-completed-\(goal.id)", date: goal.updatedAt, kind: .goalCompleted, title: "Completed \(goal.title)", detail: "Goal reached", symbolName: "checkmark.seal.fill"))
            }
            return entries
        }
        return (transactionEntries + goalEntries).sorted { $0.date > $1.date }
    }
}
