//
//  OnboardingPageView.swift
//  Awaitr
//

import SwiftUI

struct OnboardingPageView<Content: View>: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            contentArea
            textArea
            Spacer()
            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.xl)
    }

    // MARK: - Content Area

    private var contentArea: some View {
        content()
    }

    // MARK: - Text Area

    private var textArea: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.pageTitle)
                .foregroundStyle(Theme.TextColors.primary)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.TextColors.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    OnboardingPageView(
        title: "Welcome to Awaitr",
        subtitle: "Your personal waitlist manager"
    ) {
        Image(systemName: "hourglass")
            .font(Theme.Typography.largeIcon)
            .foregroundStyle(Theme.CategoryColors.job)
    }
}
