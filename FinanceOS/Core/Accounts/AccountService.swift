import Foundation
import SwiftData

enum AccountValidationError: LocalizedError, Equatable {
    case missingName
    case negativeOpeningBalance

    var errorDescription: String? {
        switch self {
        case .missingName: "Give the account a name."
        case .negativeOpeningBalance: "Opening balance cannot be negative."
        }
    }
}

/// Owns account lifecycle rules. Accounts are archived, not deleted, so history
/// remains available for future transactions, analytics, and reports.
@MainActor
final class AccountService {
    func create(name: String, type: AccountType, currencyCode: String, openingBalance: Decimal, in context: ModelContext) throws {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedName.isEmpty else { throw AccountValidationError.missingName }
        guard openingBalance >= 0 else { throw AccountValidationError.negativeOpeningBalance }

        context.insert(Account(name: normalizedName, type: type, currencyCode: currencyCode, openingBalance: openingBalance))
        try context.save()
    }

    func archive(_ account: Account, in context: ModelContext) throws {
        account.isArchived = true
        account.updatedAt = .now
        try context.save()
    }
}
