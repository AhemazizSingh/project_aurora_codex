import Foundation

enum GoalPriority: String, CaseIterable, Identifiable {
    case low, medium, high
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}
