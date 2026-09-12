import Foundation

enum GoalStatus: String, CaseIterable, Identifiable {
    case active, completed, paused, cancelled
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}
