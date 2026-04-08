//
//  MonthlyTrendsChart.swift
//  AzamCEO
//

import SwiftUI
import Charts

struct MonthlyTrendsChart: View {
    let data: [(month: String, date: Date, accepted: Int, rejected: Int)]

    private var hasData: Bool {
        data.contains { $0.accepted > 0 || $0.rejected > 0 }
    }

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("MONTHLY TRENDS")
                    .font(Theme.Typography.sectionLabel)
                    .foregroundStyle(Theme.TextColors.secondary)
                    .tracking(0.8)

                if !hasData {
                    emptyPlaceholder
                } else {
                    chartContent
                    legend
                }
            }
        }
    }

    private var chartContent: some View {
        Chart(data, id: \.month) { item in
            BarMark(
                x: .value("Month", item.month),
                y: .value("Count", item.accepted)
            )
            .foregroundStyle(Theme.CategoryColors.event)
            .accessibilityLabel("\(item.month): \(item.accepted) successful")

            BarMark(
                x: .value("Month", item.month),
                y: .value("Count", item.rejected)
            )
            .foregroundStyle(Theme.PriorityColors.high)
            .accessibilityLabel("\(item.month): \(item.rejected) unsuccessful")
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .frame(height: 160)
    }

    private var legend: some View {
        HStack(spacing: Theme.Spacing.lg) {
            legendDot(color: Theme.CategoryColors.event, label: "Successful")
            legendDot(color: Theme.PriorityColors.high, label: "Unsuccessful")
        }
    }

    private func legendDot(color: Color, label: LocalizedStringKey) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.TextColors.secondary)
        }
    }

    private var emptyPlaceholder: some View {
        Text("Not enough data")
            .font(Theme.Typography.caption)
            .foregroundStyle(Theme.TextColors.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, Theme.Spacing.lg)
    }
}
