//
//  MediumWidgetView.swift
//  AzamCEOWidget
//

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: AzamCEOWidgetEntry

    private var homeURL: URL { URL(string: "azamceo://home")! }

    private var deadlineURL: URL {
        guard let id = entry.nearestDeadlineId else { return homeURL }
        return URL(string: "azamceo://item/\(id.uuidString)")!
    }

    var body: some View {
        if entry.activeCount == 0 {
            emptyState
        } else {
            HStack(spacing: 16) {
                Link(destination: homeURL) {
                    leftColumn
                }
                Divider().frame(height: 60)
                Link(destination: deadlineURL) {
                    rightColumn
                }
            }
            .padding(4)
        }
    }

    private var emptyState: some View {
        Link(destination: homeURL) {
            HStack(spacing: 12) {
                Image("WidgetLogo")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 2) {
                    Text("All clear!")
                        .font(.callout.bold())
                        .foregroundStyle(.primary)
                    Text("Tap to add a new waitlist item")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(4)
        }
    }

    // MARK: - Left Column

    private var leftColumn: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image("WidgetLogo")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Text("AzamCEO")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            Text("\(entry.activeCount)")
                .font(.title.bold())
                .foregroundStyle(.primary)
                .contentTransition(.numericText())

            categoryPills
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var categoryPills: some View {
        HStack(spacing: 4) {
            ForEach(WaitCategory.allCases) { category in
                let count = entry.categoryBreakdown[category] ?? 0
                if count > 0 {
                    HStack(spacing: 2) {
                        Text(category.emoji)
                            .font(.caption2)
                        Text("\(count)")
                            .font(.caption2.bold())
                            .foregroundStyle(category.color)
                    }
                }
            }
        }
    }

    // MARK: - Right Column

    @ViewBuilder
    private var rightColumn: some View {
        if let title = entry.nearestDeadlineTitle,
           let date = entry.nearestDeadlineDate {
            VStack(alignment: .leading, spacing: 4) {
                Text("NEXT DEADLINE")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .tracking(0.5)

                Text(title)
                    .font(.callout.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(date, style: .relative)
                    .font(.caption)
                    .foregroundStyle(entry.nearestDeadlineCategory?.color ?? .secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Text("NO DEADLINES")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .tracking(0.5)

                Text(entry.activeCount == 0 ? "All clear!" : "No upcoming dates")
                    .font(.callout.bold())
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
