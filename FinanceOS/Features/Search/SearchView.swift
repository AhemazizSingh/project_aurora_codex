import SwiftUI
import SwiftData

struct SearchView: View {
    @Query(sort: \FinancialTransaction.date, order: .reverse) private var transactions: [FinancialTransaction]
    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \TransactionLabel.name) private var labels: [TransactionLabel]
    @Query(sort: \Goal.title) private var goals: [Goal]
    @Query(sort: \Budget.name) private var budgets: [Budget]
    @State private var query = ""

    private var results: [SearchResult] {
        SearchService.search(query: query, transactions: transactions, accounts: accounts, categories: categories, labels: labels, goals: goals, budgets: budgets)
    }

    var body: some View {
        List {
            if query.isEmpty {
                ContentUnavailableView("Search your finances", systemImage: "magnifyingglass", description: Text("Find transactions, accounts, categories, labels, goals, and budgets."))
                    .frame(maxWidth: .infinity, minHeight: 280).listRowBackground(Color.clear)
            } else if results.isEmpty {
                ContentUnavailableView.search(text: query).listRowBackground(Color.clear)
            } else {
                ForEach(results) { result in
                    HStack(spacing: 12) {
                        Image(systemName: result.symbolName).foregroundStyle(AppTheme.primary).frame(width: 28)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(result.title).font(.body.weight(.medium))
                            Text(result.subtitle).font(.caption).foregroundStyle(AppTheme.textSecondary)
                        }
                    }.padding(.vertical, 4).accessibilityElement(children: .combine)
                }
            }
        }
        .scrollContentBackground(.hidden).background(AppTheme.background)
        .navigationTitle("Search")
        .searchable(text: $query, prompt: "Search everything")
    }
}
