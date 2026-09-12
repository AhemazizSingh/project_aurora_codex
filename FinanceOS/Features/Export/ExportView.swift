import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ExportView: View {
    @Query(sort: \FinancialTransaction.date, order: .reverse) private var transactions: [FinancialTransaction]
    @State private var document: CSVDocument?
    @State private var showsExporter = false

    var body: some View {
        List {
            Section("Transactions") {
                Button { exportTransactions() } label: {
                    Label("Export transactions as CSV", systemImage: "tablecells")
                }
                Text("Exports active transactions in a spreadsheet-friendly format. Your data never leaves this device unless you choose where to share it.")
                    .font(.footnote).foregroundStyle(AppTheme.textSecondary)
            }
            Section("Coming after platform validation") {
                Label("Excel workbook", systemImage: "tablecells.badge.ellipsis").foregroundStyle(AppTheme.textSecondary)
                Label("PDF report", systemImage: "doc.richtext").foregroundStyle(AppTheme.textSecondary)
                Label("Encrypted backup", systemImage: "lock.doc").foregroundStyle(AppTheme.textSecondary)
            }
        }
        .navigationTitle("Export")
        .fileExporter(isPresented: $showsExporter, document: document, contentType: .commaSeparatedText, defaultFilename: "FinanceOS-Transactions") { _ in }
    }

    private func exportTransactions() {
        document = CSVDocument(text: CSVExportService.transactionsCSV(transactions))
        showsExporter = true
    }
}

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    var text: String
    init(text: String) { self.text = text }
    init(configuration: ReadConfiguration) throws { text = String(data: configuration.file.regularFileContents ?? Data(), encoding: .utf8) ?? "" }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: text.data(using: .utf8) ?? Data()) }
}
