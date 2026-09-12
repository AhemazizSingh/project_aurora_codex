import SwiftUI

struct InsightCard: View {
    let insight: FinancialInsight
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: insight.symbolName).font(.title3).foregroundStyle(color).frame(width: 32, height: 32).background(color.opacity(0.15), in: Circle())
            VStack(alignment: .leading, spacing: 6) {
                Text(insight.title).font(.body.weight(.semibold))
                Text(insight.explanation).font(.caption).foregroundStyle(AppTheme.textSecondary)
                Text(insight.action).font(.caption.weight(.semibold)).foregroundStyle(AppTheme.primary)
            }
        }
        .padding(18).background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var color: Color {
        switch insight.priority {
        case .critical: AppTheme.expense
        case .important: .orange
        case .suggestion: AppTheme.primary
        case .achievement: AppTheme.income
        }
    }
}
