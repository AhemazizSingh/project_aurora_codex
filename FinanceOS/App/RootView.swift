import SwiftUI

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("financeos.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("financeos.themeMode") private var themeModeRawValue = AppThemeMode.system.rawValue
    @AppStorage("financeos.deviceLockEnabled") private var deviceLockEnabled = false
    @AppStorage("financeos.autoLockSeconds") private var autoLockSeconds = 60
    @State private var isUnlocked = false
    @State private var backgroundedAt: Date?

    private var themeMode: AppThemeMode {
        AppThemeMode(rawValue: themeModeRawValue) ?? .system
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding, (!deviceLockEnabled || isUnlocked) {
                AppTabView()
            } else if hasCompletedOnboarding {
                AppLockView { isUnlocked = true }
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(themeMode.colorScheme)
        .onChange(of: deviceLockEnabled) { _, enabled in if enabled { isUnlocked = false } }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { backgroundedAt = .now }
            if phase == .active, deviceLockEnabled, let backgroundedAt, Date.now.timeIntervalSince(backgroundedAt) >= TimeInterval(autoLockSeconds) { isUnlocked = false }
        }
    }
}
