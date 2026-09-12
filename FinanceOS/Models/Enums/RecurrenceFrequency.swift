import Foundation

enum RecurrenceFrequency: String, CaseIterable, Identifiable {
    case daily, weekly, monthly, quarterly, yearly
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
    var calendarComponent: Calendar.Component {
        switch self { case .daily: .day; case .weekly: .weekOfYear; case .monthly: .month; case .quarterly: .month; case .yearly: .year }
    }
    var interval: Int { self == .quarterly ? 3 : 1 }
}
