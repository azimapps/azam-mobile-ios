//
//  GlassCard.swift
//  Awaitr
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let category: WaitCategory?
    @ViewBuilder let content: () -> Content

    init(category: WaitCategory? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.category = category
        self.content = content
    }

    var body: some View {
        content()
            .padding(Theme.Spacing.lg)
            .glassCard()
            .overlay(alignment: .topLeading) {
                if let category {
                    accentGradient(for: category)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radii.lg))
    }

    @ViewBuilder
    private func accentGradient(for category: WaitCategory) -> some View {
        RadialGradient(
            colors: [category.color.opacity(0.15), .clear],
            center: .topLeading,
            startRadius: 0,
            endRadius: 120
        )
        .allowsHitTesting(false)
    }
}

#Preview {
    VStack(spacing: 16) {
        GlassCard(category: .job) {
            Text("Job Application")
                .font(Theme.Typography.cardTitle)
        }
        GlassCard {
            Text("No category")
                .font(Theme.Typography.cardTitle)
        }
    }
    .padding()
    .background(Color.blue.opacity(0.2))
}
