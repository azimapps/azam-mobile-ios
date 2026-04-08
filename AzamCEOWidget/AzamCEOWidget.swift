//
//  AzamCEOWidget.swift
//  AzamCEOWidget
//
//  Created by ZoldyckD on 26/03/26.
//

import WidgetKit
import SwiftUI

struct AzamCEOWidget: Widget {
    let kind = "AzamCEOWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AzamCEOTimelineProvider()) { entry in
            AzamCEOWidgetEntryView(entry: entry)
                .containerBackground(.ultraThinMaterial, for: .widget)
        }
        .configurationDisplayName("AzamCEO")
        .description("Track your active waitlist items and upcoming deadlines.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Entry View Router

struct AzamCEOWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: AzamCEOWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

#Preview(as: .systemSmall) {
    AzamCEOWidget()
} timeline: {
    AzamCEOWidgetEntry.placeholder
    AzamCEOWidgetEntry.empty
}

#Preview(as: .systemMedium) {
    AzamCEOWidget()
} timeline: {
    AzamCEOWidgetEntry.placeholder
    AzamCEOWidgetEntry.empty
}
