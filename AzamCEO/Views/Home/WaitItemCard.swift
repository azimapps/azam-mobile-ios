//
//  WaitItemCard.swift
//  AzamCEO
//

import SwiftUI

struct WaitItemCard: View {
    let item: WaitItem

    private var template: PipelineTemplate { item.template }

    var body: some View {
        GlassCard(category: item.category) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                topBadgesRow
                titleText
                daysText
                MiniPipelineBar(status: item.status, template: template)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.category.shortLabel), \(item.priority.localizedName) priority")
    }

    // MARK: - Top Badges Row

    private var topBadgesRow: some View {
        HStack(spacing: Theme.Spacing.sm) {
            CategoryBadge(category: item.category)
            PriorityDot(priority: item.priority)
            Spacer()
            StatusBadge(status: item.status, template: template)
        }
    }

    // MARK: - Title

    private var titleText: some View {
        Text(item.title)
            .font(Theme.Typography.cardTitle)
            .foregroundStyle(Theme.TextColors.primary)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Days Text

    private var daysText: some View {
        Text(daysLabel)
            .font(Theme.Typography.caption)
            .foregroundStyle(Theme.TextColors.secondary)
    }

    private var daysLabel: String {
        let days = item.daysWaiting
        switch days {
        case 0: return String(localized: "Submitted today")
        case 1: return String(localized: "Submitted 1 day ago")
        default: return String(localized: "Submitted \(days) days ago")
        }
    }
}

// MARK: - Mini Pipeline Bar

struct MiniPipelineBar: View {
    let status: WaitStatus
    let template: PipelineTemplate

    private let barHeight: CGFloat = 4
    private let barSpacing: CGFloat = 4

    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(Array(template.allStagesInOrder.enumerated()), id: \.offset) { index, _ in
                bar(at: index)
            }
        }
    }

    private func bar(at index: Int) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(barColor(at: index))
            .frame(height: barHeight)
    }

    private func barColor(at index: Int) -> Color {
        switch status {
        case .positive:
            return Theme.CategoryColors.event // green for positive
        case .negative:
            return Theme.PriorityColors.high // red for negative
        default:
            guard let currentIndex = template.pipelineIndex(of: status) else {
                return Theme.GlassColors.inactiveBar
            }
            return index <= currentIndex ? Color(category: template.category) : Theme.GlassColors.inactiveBar
        }
    }
}

// MARK: - Pressable Card Style

struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(Theme.Animations.springFast, value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("Card States") {
    ScrollView {
        VStack(spacing: 16) {
            let tmpl = PipelineTemplate.jobApplication
            ForEach(tmpl.allStagesInOrder, id: \.self) { status in
                WaitItemCard(item: {
                    let item = WaitItem(title: "Sample — \(tmpl.label(for: status))", category: .job, template: tmpl, priority: .high)
                    switch status {
                    case .pending: break
                    case .active: item.transition(to: .active)
                    case .finalReview:
                        item.transition(to: .active)
                        item.transition(to: .finalReview)
                    case .positive:
                        item.transition(to: .active)
                        item.transition(to: .finalReview)
                        item.transition(to: .positive)
                    case .negative:
                        item.transition(to: .negative)
                    }
                    return item
                }())
            }
        }
        .padding()
    }
}
