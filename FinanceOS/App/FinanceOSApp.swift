import SwiftUI
import SwiftData

@main
struct FinanceOSApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
            .modelContainer(PersistenceController.shared.container)
    }
}
