import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.modelContext) private var context
    @Query private var accounts: [Account]
    @Query private var categories: [Category]
    @Query private var labels: [TransactionLabel]
    @Query(sort: \FinancialTransaction.date, order: .reverse) private var transactions: [FinancialTransaction]
    @State private var showsImporter = false
    @State private var rows: [CSVImportRow] = []
    @State private var messages: [String] = []
    @State private var alertMessage: String?
    @State private var importedSessionID: String?
    private let service = TransactionImportService()

    var body: some View {
        List {
            Section("CSV import") {
                Button { showsImporter = true } label: { Label("Choose CSV file", systemImage: "square.and.arrow.down") }
                Text("Use a CSV exported from FinanceOS. The file is read on this device and is never uploaded.").font(.footnote).foregroundStyle(AppTheme.textSecondary)
            }
            if !rows.isEmpty {
                Section("Preview") {
                    LabeledContent("Valid rows", value: "\(rows.count)")
                    ForEach(rows.prefix(8)) { row in
                        VStack(alignment: .leading) { Text("\(row.type.displayName) · \(row.amount.formatted())"); Text("Row \(row.lineNumber) · \(row.date.formatted(date: .abbreviated, time: .omitted))").font(.caption).foregroundStyle(AppTheme.textSecondary) }
                    }
                    if rows.count > 8 { Text("And \(rows.count - 8) more rows").font(.footnote).foregroundStyle(AppTheme.textSecondary) }
                    Button("Import \(rows.count) transactions") { importRows() }.disabled(!messages.isEmpty)
                }
            }
            if !messages.isEmpty { Section("Fix before importing") { ForEach(messages, id: \.self) { Text($0).foregroundStyle(AppTheme.expense) } } }
            Section("Supported columns") {
                Text("Date, Type, Amount, Currency, From Account, To Account, Category, Labels, Notes").font(.footnote).foregroundStyle(AppTheme.textSecondary)
                Text("Account, category, and label names must already exist in FinanceOS. Duplicate rows are blocked so you can review them first.").font(.footnote).foregroundStyle(AppTheme.textSecondary)
            }
            Section("Other formats") { Text("Excel and JSON import will be added after native iOS validation. CSV is deliberately supported first because it is portable and auditable.").font(.footnote).foregroundStyle(AppTheme.textSecondary) }
        }
        .navigationTitle("Import")
        .fileImporter(isPresented: $showsImporter, allowedContentTypes: [.commaSeparatedText]) { result in load(result) }
        .alert("Import", isPresented: Binding(get: { alertMessage != nil }, set: { if !$0 { alertMessage = nil } })) { Button("OK", role: .cancel) {} } message: { Text(alertMessage ?? "") }
        .safeAreaInset(edge: .bottom) { if let sessionID = importedSessionID { Button("Undo last import") { undo(sessionID) }.buttonStyle(.borderedProminent).padding().background(.bar) } }
    }

    private func load(_ result: Result<URL, Error>) {
        do {
            let url = try result.get(); let accessed = url.startAccessingSecurityScopedResource(); defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            let text = try String(contentsOf: url, encoding: .utf8)
            switch try CSVImportParser.parse(text) { case let .success(parsed): rows = parsed; messages = service.validationMessages(for: parsed, accounts: accounts, categories: categories, existing: transactions); case let .failure(errors): rows = []; messages = errors.messages }
        } catch { rows = []; messages = []; alertMessage = error.localizedDescription }
    }

    private func importRows() { do { importedSessionID = try service.import(rows, accounts: accounts, categories: categories, labels: labels, into: context); alertMessage = "Imported \(rows.count) transactions."; rows = [] } catch { alertMessage = error.localizedDescription } }
    private func undo(_ sessionID: String) { do { try service.undo(sessionID: sessionID, transactions: transactions, in: context); importedSessionID = nil; alertMessage = "The imported transactions were undone." } catch { alertMessage = error.localizedDescription } }
}
