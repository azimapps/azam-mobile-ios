//
//  SmallWidgetView.swift
//  AzamCEOWidget
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
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
            VStack(alignment: .leading, spacing: 8) {
                Link(destination: homeURL) {
                    headerRow
                }
                Spacer()
                Link(destination: deadlineURL) {
                    deadlineSection
                }
            }
            .padding(4)
        }
    }

    private var emptyState: some View {
        Link(destination: homeURL) {
            VStack(spacing: 8) {
                Image("WidgetLogo")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text("All clear!")
                    .font(.callout.bold())
                    .foregroundStyle(.primary)
                Text("Tap to add an item")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var headerRow: some View {
        HStack {
            Image("WidgetLogo")
                .resizable()
                .frame(width: 24, height: 24)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            Spacer()
            Text("\(entry.activeCount)")
                .font(.title.bold())
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
    }

    @ViewBuilder
    private var deadlineSection: some View {
        if let title = entry.nearestDeadlineTitle,
           let date = entry.nearestDeadlineDate {
            VStack(alignment: .leading, spacing: 2) {
                Text("NEXT UP")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .tracking(0.5)

                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(date, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(entry.nearestDeadlineCategory?.color ?? .secondary)
            }
        } else {
            VStack(alignment: .leading, spacing: 2) {
                Text("ACTIVE ITEMS")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .tracking(0.5)

                Text(entry.activeCount == 0 ? "All clear!" : "\(entry.activeCount) waiting")
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
            }
        }
    }
}
