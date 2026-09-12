import Foundation
import SwiftData

@Model
final class Goal: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var iconName: String
    var targetAmount: Decimal
    var savedAmount: Decimal
    var deadline: Date
    var priorityRawValue: String
    var statusRawValue: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    var linkedAccount: Account?

    init(id: UUID = UUID(), title: String, iconName: String = "target", targetAmount: Decimal, savedAmount: Decimal = 0, deadline: Date, priority: GoalPriority = .medium, notes: String = "") {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.targetAmount = targetAmount
        self.savedAmount = savedAmount
        self.deadline = deadline
        self.priorityRawValue = priority.rawValue
        self.statusRawValue = GoalStatus.active.rawValue
        self.notes = notes
        self.createdAt = .now
        self.updatedAt = .now
    }

    var priority: GoalPriority { GoalPriority(rawValue: priorityRawValue) ?? .medium }
    var status: GoalStatus { GoalStatus(rawValue: statusRawValue) ?? .active }
    var progress: Decimal { min(savedAmount / targetAmount, 1) }
    var remainingAmount: Decimal { max(targetAmount - savedAmount, 0) }
}
