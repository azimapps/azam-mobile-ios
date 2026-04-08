//
//  QuickAddWidget.swift
//  AzamCEOWidget
//

import WidgetKit
import SwiftUI

struct QuickAddWidget: Widget {
    let kind = "AzamCEOQuickAddWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickAddTimelineProvider()) { _ in
            QuickAddWidgetView()
                .containerBackground(.ultraThinMaterial, for: .widget)
        }
        .configurationDisplayName("Quick Add")
        .description("Quickly add a new waitlist item by category.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Simple provider (no data needed)

struct QuickAddTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickAddEntry {
        QuickAddEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickAddEntry) -> Void) {
        completion(QuickAddEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickAddEntry>) -> Void) {
        let entry = QuickAddEntry(date: .now)
        // Static widget — refresh daily
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct QuickAddEntry: TimelineEntry {
    let date: Date
}
