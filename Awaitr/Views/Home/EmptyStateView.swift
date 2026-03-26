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

    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer().frame(height: 60)

            Image(systemName: icon)
                .font(Theme.Typography.largeIcon)
                .foregroundStyle(Theme.TextColors.secondary)
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 20)

            Text(heading)
                .font(Theme.Typography.sectionHeader)
                .foregroundStyle(Theme.TextColors.primary)
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 20)

            Text(subheading)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.TextColors.secondary)
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 20)

            if let actionLabel, let action {
                Button(action: action) {
                    Text(actionLabel)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.CategoryColors.job)
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .accessibilityElement(children: .combine)
        .task {
            guard !hasAppeared else { return }
            withAnimation(Theme.Animations.springGentle) {
                hasAppeared = true
            }
        }
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
