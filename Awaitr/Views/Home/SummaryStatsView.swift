//
//  SummaryStatsView.swift
//  Awaitr
//

import SwiftUI

struct SummaryStatsView: View {
    let counts: [WaitCategory: Int]
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
    }

    // MARK: - Stat Cell

    private func statCell(for category: WaitCategory) -> some View {
        let isSelected = selectedCategory == category
        let count = counts[category] ?? 0

        return GlassCard(category: category) {
            VStack(spacing: Theme.Spacing.xs) {
                Text(category.emoji)
                    .font(.title2)

                Text("\(count)")
                    .font(Theme.Typography.numericCounter)
                    .foregroundStyle(Theme.TextColors.dark)

                Text(category.shortLabel)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.TextColors.muted)
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
}

#Preview {
    @Previewable @State var selected: WaitCategory? = .job

    SummaryStatsView(
        counts: [.job: 3, .product: 2, .admin: 1, .event: 2],
        selectedCategory: $selected
    )
    .padding(.vertical)
    .background(Color.blue.opacity(0.1))
}
