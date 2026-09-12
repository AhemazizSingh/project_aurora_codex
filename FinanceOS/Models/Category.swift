import Foundation
import SwiftData

@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var isArchived: Bool

    init(id: UUID = UUID(), name: String, iconName: String, colorHex: String) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.isArchived = false
    }
}
