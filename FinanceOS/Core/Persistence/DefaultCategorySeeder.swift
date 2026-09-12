import SwiftData

enum DefaultCategorySeeder {
    static func seedIfNeeded(in context: ModelContext) throws {
        guard try context.fetchCount(FetchDescriptor<Category>()) == 0 else { return }
        let definitions: [(String, String, String)] = [
            ("Food", "fork.knife", "#EF4444"),
            ("Transport", "car.fill", "#F97316"),
            ("Shopping", "bag.fill", "#8B5CF6"),
            ("Medical", "cross.case.fill", "#EC4899"),
            ("Bills", "doc.text.fill", "#3B82F6"),
            ("Entertainment", "film.fill", "#14B8A6"),
            ("Education", "book.fill", "#6366F1"),
            ("Other", "ellipsis.circle.fill", "#64748B")
        ]
        definitions.enumerated().forEach { index, definition in
            context.insert(Category(name: definition.0, iconName: definition.1, colorHex: definition.2, displayOrder: index))
        }
        try context.save()
    }
}
