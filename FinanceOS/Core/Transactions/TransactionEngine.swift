import Foundation

enum TransactionValidationError: LocalizedError, Equatable {
    case nonPositiveAmount, missingSourceAccount, missingDestinationAccount, identicalAccounts, missingExpenseCategory, insufficientFunds, invalidLoanAccounts

    var errorDescription: String? {
        switch self {
        case .nonPositiveAmount: return "Enter an amount greater than zero."
        case .missingSourceAccount: return "Choose the account the money comes from."
        case .missingDestinationAccount: return "Choose the account the money goes to."
        case .identicalAccounts: return "Choose two different accounts."
        case .missingExpenseCategory: return "Choose a category for this expense."
        case .insufficientFunds: return "This account does not have enough available funds."
        case .invalidLoanAccounts: return "A loan must move from a liability account into an asset account."
        }
    }
}

/// Central business-rule engine. Views never mutate account balances directly.
final class TransactionEngine {
    func validate(_ transaction: FinancialTransaction) throws {
        guard transaction.amount > 0 else { throw TransactionValidationError.nonPositiveAmount }
        switch transaction.type {
        case .expense:
            guard transaction.sourceAccount != nil else { throw TransactionValidationError.missingSourceAccount }
            guard transaction.category != nil else { throw TransactionValidationError.missingExpenseCategory }
        case .savings, .investment, .transfer, .loan:
            guard let source = transaction.sourceAccount else { throw TransactionValidationError.missingSourceAccount }
            guard let destination = transaction.destinationAccount else { throw TransactionValidationError.missingDestinationAccount }
            guard source.id != destination.id else { throw TransactionValidationError.identicalAccounts }
            if transaction.type == .loan, (!source.type.isLiability || !destination.type.isAsset) {
                throw TransactionValidationError.invalidLoanAccounts
            }
            if transaction.type == .savings || transaction.type == .investment {
                guard source.type.isAsset, destination.type.isAsset else { throw TransactionValidationError.invalidLoanAccounts }
            }
        case .income, .refund, .interest, .dividend, .adjustment:
            guard transaction.destinationAccount != nil else { throw TransactionValidationError.missingDestinationAccount }
        }

        if let source = transaction.sourceAccount, source.type.isAsset, transaction.type != .loan,
           source.currentBalance < transaction.amount {
            throw TransactionValidationError.insufficientFunds
        }
    }

    func apply(_ transaction: FinancialTransaction) throws {
        try validate(transaction)
        let amount = transaction.amount
        switch transaction.type {
        case .expense: debit(transaction.sourceAccount, by: amount)
        case .income, .refund, .interest, .dividend, .adjustment: credit(transaction.destinationAccount, by: amount)
        case .savings, .investment, .transfer:
            debit(transaction.sourceAccount, by: amount)
            credit(transaction.destinationAccount, by: amount)
        case .loan:
            // Liability increases and the receiving asset increases: net worth is unchanged.
            debit(transaction.sourceAccount, by: amount)
            credit(transaction.destinationAccount, by: amount)
        }
        transaction.updatedAt = .now
    }

    func reverse(_ transaction: FinancialTransaction) {
        let amount = transaction.amount
        switch transaction.type {
        case .expense: credit(transaction.sourceAccount, by: amount)
        case .income, .refund, .interest, .dividend, .adjustment: debit(transaction.destinationAccount, by: amount)
        case .savings, .investment, .transfer:
            credit(transaction.sourceAccount, by: amount)
            debit(transaction.destinationAccount, by: amount)
        case .loan:
            credit(transaction.sourceAccount, by: amount)
            debit(transaction.destinationAccount, by: amount)
        }
        transaction.updatedAt = .now
    }

    /// Debiting an asset reduces it; debiting a liability increases money owed.
    private func debit(_ account: Account?, by amount: Decimal) {
        guard let account else { return }
        account.currentBalance += account.type.isAsset ? -amount : amount
        account.updatedAt = .now
    }

    /// Crediting an asset increases it; crediting a liability reduces money owed.
    private func credit(_ account: Account?, by amount: Decimal) {
        guard let account else { return }
        account.currentBalance += account.type.isAsset ? amount : -amount
        account.updatedAt = .now
    }
}
