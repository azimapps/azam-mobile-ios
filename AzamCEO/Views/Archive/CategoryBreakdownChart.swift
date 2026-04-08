//
//  CategoryBreakdownChart.swift
//  AzamCEO
//

import SwiftUI
import Charts

struct CategoryBreakdownChart: View {
    let data: [(category: WaitCategory, count: Int)]

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("BY CATEGORY")
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
        HStack(spacing: Theme.Spacing.lg) {
            Chart(data, id: \.category) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .foregroundStyle(item.category.color)
                .accessibilityLabel("\(item.category.shortLabel): \(item.count)")
            }
            .frame(width: 90, height: 90)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(data, id: \.category) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.category.color)
                            .frame(width: 8, height: 8)
                        Text("\(item.category.emoji) \(item.category.shortLabel)")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.TextColors.primary)
                        Spacer()
                        Text("\(item.count)")
                            .font(Theme.Typography.captionBold)
                            .foregroundStyle(Theme.TextColors.secondary)
                    }
                }
            }
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
