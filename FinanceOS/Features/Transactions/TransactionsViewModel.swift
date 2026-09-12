import Foundation
import SwiftData

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published var showsAddTransaction = false
    @Published var errorMessage: String?
    private let service = TransactionService()

    func delete(_ transaction: FinancialTransaction, using context: ModelContext) {
        do { try service.softDelete(transaction, in: context) }
        catch { errorMessage = "This transaction could not be deleted. Please try again." }
    }
}
