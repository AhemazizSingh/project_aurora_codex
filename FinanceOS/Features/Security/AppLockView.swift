import SwiftUI

struct AppLockView: View {
    let onUnlock: () -> Void
    @StateObject private var authentication = DeviceAuthenticationService()
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill").font(.system(size: 48)).foregroundStyle(AppTheme.accent)
            Text("FinanceOS is locked").font(.title2.weight(.bold))
            Text("Use Face ID, Touch ID, or your device passcode to continue.").multilineTextAlignment(.center).foregroundStyle(AppTheme.textSecondary)
            Button(authentication.isAuthenticating ? "Unlocking…" : "Unlock FinanceOS") { unlock() }.buttonStyle(.borderedProminent).disabled(authentication.isAuthenticating)
            if let errorMessage { Text(errorMessage).font(.footnote).multilineTextAlignment(.center).foregroundStyle(AppTheme.expense) }
        }
        .padding(32)
        .task { unlock() }
    }

    private func unlock() {
        Task {
            switch await authentication.authenticate() {
            case .success: onUnlock()
            case let .failure(error): errorMessage = error.localizedDescription
            }
        }
    }
}
