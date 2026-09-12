import Foundation

enum AccountType: String, CaseIterable, Codable, Identifiable {
    case cash, bank, wallet, upi
    case emergencyFund, fixedDeposit, recurringDeposit, ppf, epf
    case mutualFund, stock, gold, crypto
    case creditCard, loan, other

    var id: String { rawValue }
    var isLiability: Bool { self == .creditCard || self == .loan }
    var isAsset: Bool { !isLiability }
}
