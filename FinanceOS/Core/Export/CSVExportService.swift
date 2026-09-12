import Foundation

enum CSVExportService {
    static func transactionsCSV(_ transactions: [FinancialTransaction]) -> String {
        let header = ["Date", "Type", "Amount", "Currency", "From Account", "To Account", "Category", "Labels", "Notes"]
        let rows = transactions.filter(\.isActive).sorted { $0.date > $1.date }.map { transaction in
            [
                ISO8601DateFormatter().string(from: transaction.date),
                transaction.type.rawValue,
                transaction.amount.description,
                transaction.currencyCode,
                transaction.sourceAccount?.name ?? "",
                transaction.destinationAccount?.name ?? "",
                transaction.category?.name ?? "",
                transaction.labels.map(\.name).joined(separator: "; "),
                transaction.notes
            ].map(escape).joined(separator: ",")
        }
        return ([header.map(escape).joined(separator: ",")] + rows).joined(separator: "\n")
    }

    private static func escape(_ value: String) -> String {
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
