import Foundation

struct CSVImportRow: Identifiable {
    let id = UUID()
    let lineNumber: Int
    let type: TransactionType
    let amount: Decimal
    let currencyCode: String
    let date: Date
    let sourceAccountName: String
    let destinationAccountName: String
    let categoryName: String
    let notes: String
    let labelNames: [String]
}

struct CSVImportRowErrors: Error {
    let messages: [String]
}

enum CSVImportParseError: LocalizedError {
    case emptyFile
    case missingColumns([String])

    var errorDescription: String? {
        switch self {
        case .emptyFile: return "The CSV file is empty."
        case let .missingColumns(columns): return "Missing required columns: \(columns.joined(separator: ", "))."
        }
    }
}

enum CSVImportParser {
    private static let requiredHeaders = ["Date", "Type", "Amount"]
    private static let dateFormatter = ISO8601DateFormatter()

    static func parse(_ text: String) throws -> Result<[CSVImportRow], CSVImportRowErrors> {
        let lines = text.split(whereSeparator: \.isNewline).map(String.init)
        guard let headerLine = lines.first else { throw CSVImportParseError.emptyFile }
        let headers = fields(in: headerLine).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let missing = requiredHeaders.filter { !headers.contains($0) }
        guard missing.isEmpty else { throw CSVImportParseError.missingColumns(missing) }
        let index = Dictionary(uniqueKeysWithValues: headers.enumerated().map { ($0.element, $0.offset) })
        var rows: [CSVImportRow] = []
        var errors: [String] = []
        for (offset, line) in lines.dropFirst().enumerated() where !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lineNumber = offset + 2
            let values = fields(in: line)
            func value(_ header: String) -> String { guard let position = index[header], position < values.count else { return "" }; return values[position].trimmingCharacters(in: .whitespacesAndNewlines) }
            guard let type = TransactionType(rawValue: value("Type")) else { errors.append("Row \(lineNumber): unknown transaction type."); continue }
            guard let amount = Decimal(string: value("Amount")), amount > 0 else { errors.append("Row \(lineNumber): amount must be greater than zero."); continue }
            guard let date = dateFormatter.date(from: value("Date")) else { errors.append("Row \(lineNumber): date must be ISO-8601, for example 2026-09-13T10:30:00Z."); continue }
            rows.append(CSVImportRow(lineNumber: lineNumber, type: type, amount: amount, currencyCode: value("Currency").isEmpty ? "INR" : value("Currency"), date: date, sourceAccountName: value("From Account"), destinationAccountName: value("To Account"), categoryName: value("Category"), notes: value("Notes"), labelNames: value("Labels").split(separator: ";").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }))
        }
        return errors.isEmpty ? .success(rows) : .failure(CSVImportRowErrors(messages: errors))
    }

    private static func fields(in line: String) -> [String] {
        var result: [String] = [], field = "", quoted = false
        var index = line.startIndex
        while index < line.endIndex {
            let character = line[index]
            if character == "\"" {
                let next = line.index(after: index)
                if quoted, next < line.endIndex, line[next] == "\"" { field.append("\""); index = next } else { quoted.toggle() }
            } else if character == ",", !quoted { result.append(field); field = "" } else { field.append(character) }
            index = line.index(after: index)
        }
        result.append(field)
        return result
    }
}
