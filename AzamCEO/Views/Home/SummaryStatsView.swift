//
//  SummaryStatsView.swift
//  AzamCEO
//

import SwiftUI

struct SummaryStatsView: View {
    let items: [WaitItem]
    @Binding var selectedCategory: WaitCategory?

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
            ForEach(WaitCategory.allCases) { category in
                statCell(for: category)
            }
        }
        .padding(.horizontal)
        .sensoryFeedback(.selection, trigger: selectedCategory)
    }

    // MARK: - Stat Cell

    private func statCell(for category: WaitCategory) -> some View {
        let isSelected = selectedCategory == category
        let categoryItems = items.filter { $0.category == category }
        let count = categoryItems.count

        return GlassCard(category: category) {
            VStack(spacing: Theme.Spacing.xs) {
                // Top row: emoji + label
                HStack(spacing: 4) {
                    Text(category.emoji)
                        .font(Theme.Typography.bodyMedium)
                    Text(category.shortLabel.uppercased())
                        .font(Theme.Typography.statNumber)
                        .foregroundStyle(category.color)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Big count number
                Text("\(count)")
                    .font(Theme.Typography.numericCounter)
                    .foregroundStyle(Theme.TextColors.primary)

                // Status sub-text
                Text(dominantStatusText(for: categoryItems))
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.TextColors.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radii.lg)
                .stroke(category.color, lineWidth: isSelected ? 2 : 0)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .onTapGesture {
            withAnimation(Theme.Animations.springFast) {
                selectedCategory = selectedCategory == category ? nil : category
            }
        }
        .accessibilityLabel("\(count) \(category.shortLabel) items")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Helpers

    private func dominantStatusText(for categoryItems: [WaitItem]) -> String {
        guard let first = categoryItems.first else { return String(localized: "no items") }

        // Count items per non-pending status
        var statusCounts: [WaitStatus: Int] = [:]
        var templateForStatus: [WaitStatus: PipelineTemplate] = [:]
        for item in categoryItems {
            if item.status != .pending {
                statusCounts[item.status, default: 0] += 1
                templateForStatus[item.status] = item.template
            }
        }

        // If all pending, show template-aware label
        guard let (dominantStatus, count) = statusCounts.max(by: { $0.value < $1.value }) else {
            return first.template.shortLabel(for: .pending).lowercased()
        }

        let tmpl = templateForStatus[dominantStatus] ?? first.template
        return "\(count) \(tmpl.shortLabel(for: dominantStatus).lowercased())"
    }
}

#Preview {
    @Previewable @State var selected: WaitCategory? = .job

    SummaryStatsView(
        items: [
            WaitItem(title: "Job 1", category: .job),
            WaitItem(title: "Job 2", category: .job),
            WaitItem(title: "Product 1", category: .product),
            WaitItem(title: "Event 1", category: .event),
        ],
        selectedCategory: $selected
    )
    .padding(.vertical)
    .background(Color.blue.opacity(0.1))
}
