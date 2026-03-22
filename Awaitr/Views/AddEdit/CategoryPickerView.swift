//
//  CategoryPickerView.swift
//  Awaitr
//

import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: WaitCategory

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(WaitCategory.allCases) { category in
                categoryOption(category)
            }
        }
    }

    // MARK: - Category Option

    private func categoryOption(_ category: WaitCategory) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            withAnimation(Theme.Animations.springFast) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                Text(category.emoji)
                    .font(.system(size: 16))
                Text(category.shortLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isSelected ? category.color : Theme.TextColors.muted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? category.color.opacity(0.08) : .clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? category.color : Color.black.opacity(0.06),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(category.shortLabel) category")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var category: WaitCategory = .job
    CategoryPickerView(selectedCategory: $category)
        .padding()
}
