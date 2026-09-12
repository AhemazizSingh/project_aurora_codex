import Foundation
import SwiftData

@MainActor
final class AccountsViewModel: ObservableObject {
    @Published var showsAddAccount = false
    @Published var showsArchivedAccounts = false
    @Published var hidesBalances = false
    @Published var errorMessage: String?

    let service = AccountService()

    func archive(_ account: Account, using context: ModelContext) {
        do { try service.archive(account, in: context) }
        catch { errorMessage = "This account could not be archived. Please try again." }
    }
}
