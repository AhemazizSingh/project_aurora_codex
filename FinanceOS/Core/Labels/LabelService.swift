import Foundation
import SwiftData

enum LabelValidationError: LocalizedError, Equatable {
    case missingName, duplicateName, mergeIntoSelf, labelInUse

    var errorDescription: String? {
        switch self {
        case .missingName: "Give this label a name."
        case .duplicateName: "A label with this name already exists."
        case .mergeIntoSelf: "Choose a different label to merge into."
        case .labelInUse: "This label is used by transactions. Merge or archive it instead."
        }
    }
}

@MainActor
final class LabelService {
    func create(name: String, in context: ModelContext) throws {
        let normalizedName = try validatedName(name, excluding: nil, in: context)
        context.insert(TransactionLabel(name: normalizedName))
        try context.save()
    }

    func rename(_ label: TransactionLabel, to name: String, in context: ModelContext) throws {
        label.name = try validatedName(name, excluding: label.id, in: context)
        label.updatedAt = .now
        try context.save()
    }

    func archive(_ label: TransactionLabel, in context: ModelContext) throws {
        label.isArchived = true
        label.updatedAt = .now
        try context.save()
    }

    func merge(_ source: TransactionLabel, into destination: TransactionLabel, in context: ModelContext) throws {
        guard source.id != destination.id else { throw LabelValidationError.mergeIntoSelf }
        let transactions = try context.fetch(FetchDescriptor<FinancialTransaction>())
        for transaction in transactions where transaction.labels.contains(where: { $0.id == source.id }) {
            transaction.labels.removeAll { $0.id == source.id }
            if !transaction.labels.contains(where: { $0.id == destination.id }) { transaction.labels.append(destination) }
            transaction.updatedAt = .now
        }
        source.isArchived = true
        source.updatedAt = .now
        try context.save()
    }

    func deleteUnused(_ label: TransactionLabel, in context: ModelContext) throws {
        let transactions = try context.fetch(FetchDescriptor<FinancialTransaction>())
        guard !transactions.contains(where: { $0.labels.contains(where: { $0.id == label.id }) }) else { throw LabelValidationError.labelInUse }
        context.delete(label)
        try context.save()
    }

    private func validatedName(_ name: String, excluding labelID: UUID?, in context: ModelContext) throws -> String {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { throw LabelValidationError.missingName }
        let labels = try context.fetch(FetchDescriptor<TransactionLabel>())
        guard !labels.contains(where: { $0.id != labelID && $0.name.caseInsensitiveCompare(normalized) == .orderedSame }) else {
            throw LabelValidationError.duplicateName
        }
        return normalized
    }
}
