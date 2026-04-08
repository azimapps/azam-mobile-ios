//
//  CategoryFilterBar.swift
//  AzamCEO
//

import SwiftUI

struct CategoryFilterBar: View {
    @Binding var selectedCategory: WaitCategory?
    let totalCount: Int
    @Namespace private var pillNamespace

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                filterPill(label: String(localized: "All (\(totalCount))"), category: nil)

                ForEach(WaitCategory.allCases) { category in
                    filterPill(
                        label: "\(category.emoji) \(category.shortLabel)",
                        category: category
                    )
                }
            }
            .padding(.horizontal)
        }
        .sensoryFeedback(.selection, trigger: selectedCategory)
    }

    // MARK: - Filter Pill

    private func filterPill(label: String, category: WaitCategory?) -> some View {
        let isSelected = selectedCategory == category
        let tintColor = category?.color ?? Theme.CategoryColors.job

        return Text(label)
            .font(Theme.Typography.caption)
            .foregroundStyle(isSelected ? tintColor : Theme.TextColors.secondary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background {
                if isSelected {
                    Capsule()
                        .fill(tintColor.opacity(0.12))
                        .matchedGeometryEffect(id: "pill", in: pillNamespace)
                } else {
                    Capsule()
                        .fill(Theme.GlassColors.fill)
                        .overlay(
                            Capsule()
                                .stroke(Theme.GlassColors.border, lineWidth: 1)
                        )
                }
            }
            .onTapGesture {
                withAnimation(Theme.Animations.springFast) {
                    selectedCategory = category
                }
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var selected: WaitCategory?

    VStack {
        CategoryFilterBar(selectedCategory: $selected, totalCount: 10)
        Text("Selected: \(selected?.shortLabel ?? "All")")
    }
    .padding(.vertical)
}
