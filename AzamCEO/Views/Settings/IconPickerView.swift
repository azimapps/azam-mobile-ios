//
//  IconPickerView.swift
//  AzamCEO
//

import SwiftUI

struct IconPickerView: View {
    let selectedIconId: String?
    let onSelect: (String?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("APP ICON")
                .font(Theme.Typography.sectionLabel)
                .foregroundStyle(Theme.TextColors.secondary)
                .tracking(0.8)
                .padding(.horizontal, Theme.Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.md) {
                    ForEach(AppIconOption.allOptions) { option in
                        iconTile(option)
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
        }
    }

    private func iconTile(_ option: AppIconOption) -> some View {
        let isSelected = selectedIconId == option.id

        return VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: option.previewColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                // Hourglass icon to match actual app icon
                Image(systemName: "hourglass")
                    .font(.title2.bold())
                    .foregroundStyle(.white.opacity(0.9))

                if isSelected {
                    selectionOverlay
                }
            }

            Text(option.displayName)
                .font(Theme.Typography.caption)
                .foregroundStyle(isSelected ? Theme.CategoryColors.job : Theme.TextColors.secondary)
        }
        .onTapGesture {
            withAnimation(Theme.Animations.springFast) {
                onSelect(option.id)
            }
        }
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var selectionOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.CategoryColors.job, lineWidth: 2.5)
                .frame(width: 64, height: 64)

            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.white)
                .background(Circle().fill(Theme.CategoryColors.job).frame(width: 16, height: 16))
                .offset(x: 24, y: -24)
        }
    }
}
