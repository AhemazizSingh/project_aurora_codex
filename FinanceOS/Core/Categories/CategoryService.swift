import Foundation
import SwiftData

enum CategoryValidationError: LocalizedError, Equatable {
    case missingName, duplicateName, mergeIntoSelf, categoryInUse

    var errorDescription: String? {
        switch self {
        case .missingName: "Give this category a name."
        case .duplicateName: "A category with this name already exists."
        case .mergeIntoSelf: "Choose a different category to merge into."
        case .categoryInUse: "This category has transactions. Merge or archive it instead."
        }
    }
}

/// Manages the category lifecycle while preserving transactional history.
@MainActor
final class CategoryService {
    func create(name: String, iconName: String, colorHex: String, in context: ModelContext) throws {
        let normalizedName = try validatedName(name, excluding: nil, in: context)
        let order = try context.fetch(FetchDescriptor<Category>()).map(\.displayOrder).max() ?? -1
        context.insert(Category(name: normalizedName, iconName: iconName, colorHex: colorHex, displayOrder: order + 1))
        try context.save()
    }

    func update(_ category: Category, name: String, iconName: String, colorHex: String, in context: ModelContext) throws {
        category.name = try validatedName(name, excluding: category.id, in: context)
        category.iconName = iconName
        category.colorHex = colorHex
        category.updatedAt = .now
        try context.save()
    }

    func archive(_ category: Category, in context: ModelContext) throws {
        category.isArchived = true
        category.updatedAt = .now
        try context.save()
    }

    func merge(_ source: Category, into destination: Category, in context: ModelContext) throws {
        guard source.id != destination.id else { throw CategoryValidationError.mergeIntoSelf }
        let transactions = try context.fetch(FetchDescriptor<FinancialTransaction>())
        transactions.filter { $0.category?.id == source.id }.forEach { $0.category = destination; $0.updatedAt = .now }
        source.isArchived = true
        source.updatedAt = .now
        try context.save()
    }

    func deleteUnused(_ category: Category, in context: ModelContext) throws {
        let transactions = try context.fetch(FetchDescriptor<FinancialTransaction>())
        guard !transactions.contains(where: { $0.category?.id == category.id }) else {
            throw CategoryValidationError.categoryInUse
        }
        context.delete(category)
        try context.save()
    }

    func reorder(_ categories: [Category], from source: IndexSet, to destination: Int, in context: ModelContext) throws {
        var reordered = categories
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, category) in reordered.enumerated() {
            category.displayOrder = index
            category.updatedAt = .now
        }
        try context.save()
    }

    private func validatedName(_ name: String, excluding categoryID: UUID?, in context: ModelContext) throws -> String {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { throw CategoryValidationError.missingName }
        let existing = try context.fetch(FetchDescriptor<Category>())
        let duplicate = existing.contains { $0.id != categoryID && $0.name.caseInsensitiveCompare(normalized) == .orderedSame }
        guard !duplicate else { throw CategoryValidationError.duplicateName }
        return normalized
    }
}
