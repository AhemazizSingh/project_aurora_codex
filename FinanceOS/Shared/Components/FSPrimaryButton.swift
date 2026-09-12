import SwiftUI

struct FSPrimaryButton: View {
    let title: String
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.primary)
        .disabled(isDisabled)
        .accessibilityHint(isDisabled ? "Complete the required information first." : "")
    }
}
