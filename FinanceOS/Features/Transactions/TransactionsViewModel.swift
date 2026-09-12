import Foundation
import SwiftData

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published var showsAddTransaction = false
    @Published var undoableTransaction: FinancialTransaction?
    @Published var editingTransaction: FinancialTransaction?
    @Published var errorMessage: String?
    private let service = TransactionService()

    func delete(_ transaction: FinancialTransaction, using context: ModelContext) {
        do { try service.softDelete(transaction, in: context); undoableTransaction = transaction }
        catch { errorMessage = "This transaction could not be deleted. Please try again." }
    }

    func undoDelete(using context: ModelContext) {
        guard let transaction = undoableTransaction else { return }
        do { try service.restore(transaction, in: context); undoableTransaction = nil }
        catch { errorMessage = "This transaction could not be restored. Please try again." }
    }
}
