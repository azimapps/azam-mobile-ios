//
//  ArchiveItemCard.swift
//  AzamCEO
//

import SwiftUI

struct ArchiveItemCard: View {
    let item: WaitItem

    private var isPositive: Bool { item.status.isPositive }

    private var outcomeColor: Color {
        isPositive ? Theme.CategoryColors.event : Theme.PriorityColors.high
    }

    private var outcomeIcon: String {
        isPositive ? "checkmark" : "xmark"
    }

    private var subtitle: String {
        let statusLabel = item.template.label(for: item.status)
        let date = item.updatedAt.shortFormatted
        let days = item.daysWaiting
        let dayText = days == 1 ? String(localized: "1 day wait") : String(localized: "\(days) days wait")
        return "\(statusLabel) \(date) — \(dayText)"
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            outcomeCircle
            textContent
            Spacer(minLength: 4)
            CategoryBadge(category: item.category)
        }
        .padding(Theme.Spacing.md)
        .glassCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.category.shortLabel), \(item.template.label(for: item.status))")
    }

    // MARK: - Outcome Circle

    private var outcomeCircle: some View {
        Image(systemName: outcomeIcon)
            .font(Theme.Typography.captionBold)
            .foregroundStyle(outcomeColor)
            .frame(width: 28, height: 28)
            .background(outcomeColor.opacity(0.12))
            .clipShape(Circle())
    }

    // MARK: - Text Content

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.title)
                .font(Theme.Typography.buttonLabel)
                .foregroundStyle(Theme.TextColors.primary)
                .lineLimit(1)
            Text(subtitle)
                .font(Theme.Typography.sectionLabel)
                .foregroundStyle(Theme.TextColors.secondary)
                .lineLimit(1)
        }
    }
}
