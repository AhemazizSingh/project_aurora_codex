import Foundation
import SwiftData

@Model
final class Category: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var isArchived: Bool
    var displayOrder: Int
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), name: String, iconName: String, colorHex: String, displayOrder: Int = 0) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.isArchived = false
        self.displayOrder = displayOrder
        self.createdAt = .now
        self.updatedAt = .now
    }
}
