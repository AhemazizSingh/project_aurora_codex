import Foundation

enum AccountType: String, CaseIterable, Codable, Identifiable {
    case cash, bank, wallet, upi
    case emergencyFund, fixedDeposit, recurringDeposit, ppf, epf
    case mutualFund, stock, gold, crypto
    case creditCard, loan, other

    var id: String { rawValue }
    var isLiability: Bool { self == .creditCard || self == .loan }
    var isAsset: Bool { !isLiability }

    var displayName: String {
        switch self {
        case .emergencyFund: "Emergency Fund"
        case .fixedDeposit: "Fixed Deposit"
        case .recurringDeposit: "Recurring Deposit"
        case .mutualFund: "Mutual Fund"
        case .creditCard: "Credit Card"
        default: rawValue.capitalized
        }
    }

    var symbolName: String {
        switch self {
        case .cash: "banknote"
        case .bank: "building.columns"
        case .wallet: "wallet.pass"
        case .upi: "qrcode"
        case .emergencyFund: "shield.fill"
        case .fixedDeposit, .recurringDeposit: "lock.fill"
        case .ppf, .epf: "shield.checkered"
        case .mutualFund, .stock: "chart.line.uptrend.xyaxis"
        case .gold: "circle.hexagongrid.fill"
        case .crypto: "bitcoinsign.circle"
        case .creditCard: "creditcard.fill"
        case .loan: "building.columns.fill"
        case .other: "ellipsis.circle"
        }
    }
}
