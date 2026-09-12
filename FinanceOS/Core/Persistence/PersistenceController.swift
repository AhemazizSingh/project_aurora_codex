import SwiftData

@MainActor
final class PersistenceController {
    static let shared = PersistenceController()
    let container: ModelContainer

    private init(inMemory: Bool = false) {
        let schema = Schema([Account.self, Category.self, FinancialTransaction.self])
        let configuration = ModelConfiguration("FinanceOS", schema: schema, isStoredInMemoryOnly: inMemory)
        do { container = try ModelContainer(for: schema, configurations: [configuration]) }
        catch { fatalError("Unable to create the FinanceOS data store: \(error)") }
    }

    static func previewContainer() -> ModelContainer { PersistenceController(inMemory: true).container }
}
