import SwiftUI

struct RootView: View {
    @AppStorage("financeos.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("financeos.themeMode") private var themeModeRawValue = AppThemeMode.system.rawValue

    private var themeMode: AppThemeMode {
        AppThemeMode(rawValue: themeModeRawValue) ?? .system
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                DashboardView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(themeMode.colorScheme)
    }
}
