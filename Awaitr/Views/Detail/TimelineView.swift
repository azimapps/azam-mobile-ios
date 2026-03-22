//
//  TimelineView.swift
//  Awaitr
//

import SwiftUI

struct TimelineView: View {
    let entries: [StatusEntry]
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
                        .fill(Color(hex: "6C63FF").opacity(0.15))
                        .frame(width: 2)
                        .frame(minHeight: 28)
                }
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.status.label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.TextColors.dark)

                Text("\(entry.timestamp.shortFormatted) — \(entry.timestamp.relativeString)")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.TextColors.muted)
            }
            .padding(.bottom, isLast ? 0 : 8)
        }
    }
}

#Preview {
    TimelineView(
        entries: [
            StatusEntry(status: .submitted, timestamp: Calendar.current.date(byAdding: .day, value: -12, to: .now)!),
            StatusEntry(status: .inReview, timestamp: Calendar.current.date(byAdding: .day, value: -6, to: .now)!)
        ],
        categoryColor: Theme.CategoryColors.job
    )
    .padding()
}
