import Foundation
import SwiftData

enum BudgetValidationError: LocalizedError, Equatable {
    case missingName, nonPositiveAmount, missingCategory, invalidCustomRange

    var errorDescription: String? {
        switch self {
        case .missingName: "Give this budget a name."
        case .nonPositiveAmount: "Budget amount must be greater than zero."
        case .missingCategory: "Choose a category for this budget."
        case .invalidCustomRange: "Choose a custom end date after the start date."
        }
    }
}

@MainActor
final class BudgetService {
    func create(name: String, amount: Decimal, period: BudgetPeriod, category: Category?, customStartDate: Date?, customEndDate: Date?, in context: ModelContext) throws {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedName.isEmpty else { throw BudgetValidationError.missingName }
        guard amount > 0 else { throw BudgetValidationError.nonPositiveAmount }
        guard let category else { throw BudgetValidationError.missingCategory }
        if period == .custom {
            guard let customStartDate, let customEndDate, customStartDate < customEndDate else {
                throw BudgetValidationError.invalidCustomRange
            }
        }
        context.insert(Budget(name: normalizedName, amount: amount, period: period, category: category, customStartDate: customStartDate, customEndDate: customEndDate))
        try context.save()
    }

    func archive(_ budget: Budget, in context: ModelContext) throws {
        budget.isArchived = true
        budget.updatedAt = .now
        try context.save()
    }
}

enum BudgetEngine {
    static func currentRange(for budget: Budget, now: Date = .now, calendar: Calendar = .current) -> DateInterval? {
        switch budget.period {
        case .weekly:
            return calendar.dateInterval(of: .weekOfYear, for: now)
        case .monthly:
            return calendar.dateInterval(of: .month, for: now)
        case .quarterly:
            let month = calendar.component(.month, from: now)
            let quarterStartMonth = ((month - 1) / 3) * 3 + 1
            guard let start = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: quarterStartMonth)) else { return nil }
            guard let end = calendar.date(byAdding: .month, value: 3, to: start) else { return nil }
            return DateInterval(start: start, end: end)
        case .yearly:
            return calendar.dateInterval(of: .year, for: now)
        case .custom:
            guard let start = budget.customStartDate, let end = budget.customEndDate else { return nil }
            return DateInterval(start: start, end: end)
        }
    }

    static func spent(for budget: Budget, transactions: [FinancialTransaction], now: Date = .now) -> Decimal {
        guard let categoryID = budget.category?.id, let range = currentRange(for: budget, now: now) else { return 0 }
        return transactions.filter { $0.isActive && $0.category?.id == categoryID && range.contains($0.date) }.reduce(0) { total, transaction in
            switch transaction.type {
            case .expense: total + transaction.amount
            case .refund: total - transaction.amount
            default: total
            }
        }
    }
}
