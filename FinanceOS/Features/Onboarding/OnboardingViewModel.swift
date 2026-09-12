import Foundation
import SwiftData

@MainActor
final class OnboardingViewModel: ObservableObject {
    enum Step: Int, CaseIterable {
        case welcome, overview, appearance, currency, firstAccount, ready
    }

    @Published var step: Step = .welcome
    @Published var name = ""
    @Published var currencyCode = "INR"
    @Published var themeMode: AppThemeMode = .system
    @Published var accountName = ""
    @Published var accountType: AccountType = .bank
    @Published var openingBalanceText = ""
    @Published var errorMessage: String?

    let currencies = [("INR", "Indian Rupee (₹)"), ("USD", "US Dollar ($)"), ("EUR", "Euro (€)"), ("GBP", "British Pound (£)")]

    var isLastStep: Bool { step == .ready }

    func advance() {
        guard let next = Step(rawValue: step.rawValue + 1) else { return }
        step = next
    }

    func goBack() {
        guard let previous = Step(rawValue: step.rawValue - 1) else { return }
        step = previous
    }

    func complete(using context: ModelContext) {
        let trimmedName = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Give your first account a name to continue."
            step = .firstAccount
            return
        }

        let amount = Decimal(string: openingBalanceText) ?? 0
        guard amount >= 0 else {
            errorMessage = "Opening balance cannot be negative."
            step = .firstAccount
            return
        }

        let account = Account(name: trimmedName, type: accountType, currencyCode: currencyCode, openingBalance: amount)
        context.insert(account)
        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: "financeos.hasCompletedOnboarding")
            UserDefaults.standard.set(currencyCode, forKey: "financeos.currencyCode")
            UserDefaults.standard.set(themeMode.rawValue, forKey: "financeos.themeMode")
            UserDefaults.standard.set(name.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "financeos.userName")
        } catch {
            errorMessage = "Your first account could not be saved. Please try again."
        }
    }
}
