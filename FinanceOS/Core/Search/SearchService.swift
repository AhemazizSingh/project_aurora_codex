import Foundation

enum SearchResult: Identifiable {
    case transaction(FinancialTransaction)
    case account(Account)
    case category(Category)
    case label(TransactionLabel)
    case goal(Goal)
    case budget(Budget)

    var id: UUID {
        switch self {
        case .transaction(let item): item.id
        case .account(let item): item.id
        case .category(let item): item.id
        case .label(let item): item.id
        case .goal(let item): item.id
        case .budget(let item): item.id
        }
    }

    var title: String {
        switch self {
        case .transaction(let item): item.category?.name ?? item.type.displayName
        case .account(let item): item.name
        case .category(let item): item.name
        case .label(let item): item.name
        case .goal(let item): item.title
        case .budget(let item): item.name
        }
    }

    var subtitle: String {
        switch self {
        case .transaction(let item): "Transaction · \(AnalyticsCurrency.string(item.amount))"
        case .account: "Account"
        case .category: "Category"
        case .label: "Label"
        case .goal: "Goal"
        case .budget: "Budget"
        }
    }

    var symbolName: String {
        switch self {
        case .transaction(let item): item.type.symbolName
        case .account(let item): item.type.symbolName
        case .category(let item): item.iconName
        case .label(let item): item.iconName
        case .goal(let item): item.iconName
        case .budget: "chart.pie"
        }
    }
}

enum SearchService {
    static func search(query: String, transactions: [FinancialTransaction], accounts: [Account], categories: [Category], labels: [TransactionLabel], goals: [Goal], budgets: [Budget]) -> [SearchResult] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        func matches(_ text: String) -> Bool { text.localizedCaseInsensitiveContains(query) }
        let transactionResults = transactions.filter { item in
            item.isActive && (matches(item.notes) || matches(item.category?.name ?? "") || matches(item.sourceAccount?.name ?? "") || matches(item.destinationAccount?.name ?? "") || matches(item.type.displayName) || matches(item.amount.description) || item.labels.contains { matches($0.name) })
        }.map(SearchResult.transaction)
        return transactionResults
            + accounts.filter { matches($0.name) && !$0.isArchived }.map(SearchResult.account)
            + categories.filter { matches($0.name) && !$0.isArchived }.map(SearchResult.category)
            + labels.filter { matches($0.name) && !$0.isArchived }.map(SearchResult.label)
            + goals.filter { matches($0.title) || matches($0.notes) }.map(SearchResult.goal)
            + budgets.filter { matches($0.name) && !$0.isArchived }.map(SearchResult.budget)
    }
}
