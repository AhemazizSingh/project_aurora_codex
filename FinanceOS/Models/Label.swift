import Foundation
import SwiftData

@Model
final class TransactionLabel: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var iconName: String
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), name: String, colorHex: String = "#3B82F6", iconName: String = "tag.fill") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.isArchived = false
        self.createdAt = .now
        self.updatedAt = .now
    }
}
