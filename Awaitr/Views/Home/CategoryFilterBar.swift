//
//  CategoryFilterBar.swift
//  Awaitr
//

import SwiftUI

struct CategoryFilterBar: View {
    @Binding var selectedCategory: WaitCategory?
    @Namespace private var pillNamespace

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                filterPill(label: "All", category: nil)

                ForEach(WaitCategory.allCases) { category in
                    filterPill(label: category.shortLabel, category: category)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Filter Pill

    private func filterPill(label: String, category: WaitCategory?) -> some View {
        let isSelected = selectedCategory == category

        return Text(label)
            .font(Theme.Typography.caption)
            .foregroundStyle(isSelected ? .white : Theme.TextColors.dark)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background {
                if isSelected {
                    Capsule()
                        .fill(category?.color ?? Theme.TextColors.dark)
                        .matchedGeometryEffect(id: "pill", in: pillNamespace)
                } else {
                    Capsule()
                        .fill(.ultraThinMaterial)
                }
            }
            .onTapGesture {
                withAnimation(Theme.Animations.springFast) {
                    selectedCategory = category
                }
            }
    }
}

#Preview {
    @Previewable @State var selected: WaitCategory?

    VStack {
        CategoryFilterBar(selectedCategory: $selected)
        Text("Selected: \(selected?.shortLabel ?? "All")")
    }
    .padding(.vertical)
}
