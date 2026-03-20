//
//  EmptyStateView.swift
//  Awaitr
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let heading: LocalizedStringKey
    let subheading: LocalizedStringKey
    var actionLabel: LocalizedStringKey?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer().frame(height: 60)

            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Theme.TextColors.muted)

            Text(heading)
                .font(Theme.Typography.sectionHeader)
                .foregroundStyle(Theme.TextColors.dark)

            Text(subheading)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.TextColors.muted)

            if let actionLabel, let action {
                Button(action: action) {
                    Text(actionLabel)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.CategoryColors.job)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    EmptyStateView(
        icon: "tray",
        heading: "Nothing to wait for!",
        subheading: "Tap + to add your first item",
        actionLabel: "Add Item",
        action: {}
    )
}
