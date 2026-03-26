//
//  TimelineView.swift
//  Awaitr
//

import SwiftUI

struct StatusTimelineView: View {
    let entries: [StatusEntry]
    let template: PipelineTemplate
    let categoryColor: Color

    private var reversedEntries: [StatusEntry] {
        entries.reversed()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(reversedEntries.enumerated()), id: \.element.id) { index, entry in
                timelineEntry(entry, index: index, isLast: index == reversedEntries.count - 1)
            }
        }
    }

    // MARK: - Entry

    private func timelineEntry(_ entry: StatusEntry, index: Int, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Dot + connecting line
            VStack(spacing: 0) {
                Circle()
                    .fill(categoryColor.opacity(index == 0 ? 1 : 0.5))
                    .frame(width: 10, height: 10)
                    .padding(.top, 3)

                if !isLast {
                    Rectangle()
                        .fill(Theme.CategoryColors.job.opacity(0.15))
                        .frame(width: 2)
                        .frame(minHeight: 28)
                }
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(template.label(for: entry.status))
                    .font(Theme.Typography.captionBold)
                    .foregroundStyle(Theme.TextColors.primary)

                Text("\(entry.timestamp.shortFormatted) — \(entry.timestamp.relativeString)")
                    .font(Theme.Typography.smallLabel)
                    .foregroundStyle(Theme.TextColors.secondary)
            }
            .padding(.bottom, isLast ? 0 : 8)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StatusTimelineView(
        entries: [
            StatusEntry(status: .pending, timestamp: Calendar.current.date(byAdding: .day, value: -12, to: .now)!),
            StatusEntry(status: .active, timestamp: Calendar.current.date(byAdding: .day, value: -6, to: .now)!)
        ],
        template: .jobApplication,
        categoryColor: Theme.CategoryColors.job
    )
    .padding()
}
