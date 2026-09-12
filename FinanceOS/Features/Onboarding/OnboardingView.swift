import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("financeos.themeMode") private var themeModeRawValue = AppThemeMode.system.rawValue
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                progressHeader
                TabView(selection: $viewModel.step) {
                    welcome.tag(OnboardingViewModel.Step.welcome)
                    overview.tag(OnboardingViewModel.Step.overview)
                    appearance.tag(OnboardingViewModel.Step.appearance)
                    currency.tag(OnboardingViewModel.Step.currency)
                    firstAccount.tag(OnboardingViewModel.Step.firstAccount)
                    ready.tag(OnboardingViewModel.Step.ready)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.smooth, value: viewModel.step)
                controls
            }
            .padding(.horizontal, 24)
        }
        .foregroundStyle(AppTheme.textPrimary)
        .alert("Something needs attention", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var progressHeader: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingViewModel.Step.allCases, id: \.rawValue) { step in
                Capsule()
                    .fill(step.rawValue <= viewModel.step.rawValue ? AppTheme.primary : AppTheme.surface)
                    .frame(height: 4)
            }
        }
        .padding(.top, 16)
        .accessibilityLabel("Onboarding step \(viewModel.step.rawValue + 1) of \(OnboardingViewModel.Step.allCases.count)")
    }

    private var controls: some View {
        HStack(spacing: 12) {
            if viewModel.step != .welcome {
                Button("Back", action: viewModel.goBack)
                    .buttonStyle(.bordered)
                    .tint(AppTheme.textSecondary)
                    .frame(minHeight: 52)
            }
            FSPrimaryButton(title: viewModel.isLastStep ? "Open FinanceOS" : "Continue") {
                if viewModel.isLastStep {
                    viewModel.complete(using: modelContext)
                } else {
                    if viewModel.step == .appearance { themeModeRawValue = viewModel.themeMode.rawValue }
                    viewModel.advance()
                }
            }
        }
        .padding(.vertical, 24)
    }

    private var welcome: some View {
        OnboardingPage(icon: "chart.line.uptrend.xyaxis", title: "See your money clearly.", subtitle: "FinanceOS keeps every financial movement in one calm, private place.") {
            TextField("What should we call you?", text: $viewModel.name)
                .textContentType(.name)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var overview: some View {
        OnboardingPage(icon: "lock.shield.fill", title: "Private by design.", subtitle: "Your financial data stays on your device. Savings, investments, and transfers are never treated as expenses.") {
            Label("Offline-first", systemImage: "checkmark.circle.fill")
            Label("Built for your net worth", systemImage: "checkmark.circle.fill")
        }
    }

    private var appearance: some View {
        OnboardingPage(icon: "circle.lefthalf.filled", title: "Make it yours.", subtitle: "Choose an appearance. You can change this at any time in Settings.") {
            Picker("Appearance", selection: $viewModel.themeMode) {
                ForEach(AppThemeMode.allCases) { mode in Text(mode.title).tag(mode) }
            }
            .pickerStyle(.segmented)
        }
    }

    private var currency: some View {
        OnboardingPage(icon: "indianrupeesign.circle.fill", title: "Choose your currency.", subtitle: "All summaries and account balances will use this as their starting currency.") {
            Picker("Currency", selection: $viewModel.currencyCode) {
                ForEach(viewModel.currencies, id: \.0) { code, title in Text(title).tag(code) }
            }
            .pickerStyle(.navigationLink)
        }
    }

    private var firstAccount: some View {
        OnboardingPage(icon: "building.columns.fill", title: "Add your first account.", subtitle: "Start with where your money is today. You can add more accounts later.") {
            TextField("Account name", text: $viewModel.accountName)
                .textFieldStyle(.roundedBorder)
            Picker("Account type", selection: $viewModel.accountType) {
                ForEach(AccountType.allCases) { type in
                    Label(type.displayName, systemImage: type.symbolName).tag(type)
                }
            }
            TextField("Opening balance", text: $viewModel.openingBalanceText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var ready: some View {
        OnboardingPage(icon: "sparkles", title: "You’re ready, \(viewModel.name.isEmpty ? "there" : viewModel.name).", subtitle: "Your dashboard will show the financial picture that matters—without the noise.") {
            Label("Your first account is ready to save", systemImage: "checkmark.seal.fill")
                .foregroundStyle(AppTheme.income)
        }
    }
}

private struct OnboardingPage<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(AppTheme.primary)
                .accessibilityHidden(true)
            Text(title).font(.system(size: 32, weight: .bold, design: .rounded))
            Text(subtitle).font(.body).foregroundStyle(AppTheme.textSecondary)
            VStack(alignment: .leading, spacing: 16) { content }
                .padding(20)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
            Spacer()
        }
        .padding(.vertical, 16)
    }
}
