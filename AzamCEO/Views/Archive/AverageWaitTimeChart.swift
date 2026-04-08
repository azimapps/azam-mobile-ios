//
//  AverageWaitTimeChart.swift
//  AzamCEO
//

import SwiftUI
import Charts

struct AverageWaitTimeChart: View {
    let data: [(category: WaitCategory, avgDays: Double)]

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("AVG. WAIT TIME")
                    .font(Theme.Typography.sectionLabel)
                    .foregroundStyle(Theme.TextColors.secondary)
                    .tracking(0.8)

                if data.isEmpty {
                    emptyPlaceholder
                } else {
                    chartContent
                }
            }
        }
    }

    private var chartContent: some View {
        Chart(data, id: \.category) { item in
            BarMark(
                x: .value("Days", item.avgDays),
                y: .value("Category", item.category.shortLabel)
            )
            .foregroundStyle(item.category.color)
            .annotation(position: .trailing, spacing: 4) {
                Text("\(Int(item.avgDays))d")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.TextColors.secondary)
            }
            .accessibilityLabel("\(item.category.shortLabel): \(Int(item.avgDays)) days average")
        }
        .chartXAxis(.hidden)
        .frame(height: CGFloat(data.count) * 40 + 20)
    }

    private var emptyPlaceholder: some View {
        Text("Not enough data")
            .font(Theme.Typography.caption)
            .foregroundStyle(Theme.TextColors.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, Theme.Spacing.lg)
    }
}
