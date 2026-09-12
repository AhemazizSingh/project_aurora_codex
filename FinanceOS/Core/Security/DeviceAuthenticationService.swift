import Foundation
import Combine
import LocalAuthentication

@MainActor
final class DeviceAuthenticationService: ObservableObject {
    @Published private(set) var isAuthenticating = false

    func authenticate() async -> Result<Void, Error> {
        let context = LAContext()
        var policyError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &policyError) else {
            return .failure(policyError ?? AuthenticationError.unavailable)
        }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock FinanceOS to view your financial data.")
            return .success(())
        } catch { return .failure(error) }
    }
}

enum AuthenticationError: LocalizedError {
    case unavailable
    var errorDescription: String? { "Device authentication is not available. Set up Face ID, Touch ID, or a device passcode before enabling app lock." }
}
