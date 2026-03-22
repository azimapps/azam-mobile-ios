//
//  ArchiveItemCard.swift
//  Awaitr
//

import SwiftUI

struct ArchiveItemCard: View {
    let item: WaitItem

    private var isAccepted: Bool { item.status == .accepted }

    private var outcomeColor: Color {
        isAccepted ? Color(hex: "3B6D11") : Color(hex: "E24B4A")
    }

    private var outcomeIcon: String {
        isAccepted ? "checkmark" : "xmark"
    }

    private var subtitle: String {
        let statusLabel = item.status.label
        let date = item.updatedAt.shortFormatted
        let days = item.daysWaiting
        let dayText = days == 1 ? "1 day wait" : "\(days) days wait"
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
    }

    // MARK: - Outcome Circle

    private var outcomeCircle: some View {
        Image(systemName: outcomeIcon)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(outcomeColor)
            .frame(width: 28, height: 28)
            .background(outcomeColor.opacity(0.12))
            .clipShape(Circle())
    }

    // MARK: - Text Content

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.TextColors.dark)
                .lineLimit(1)
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundStyle(Theme.TextColors.muted)
                .lineLimit(1)
        }
    }
}
