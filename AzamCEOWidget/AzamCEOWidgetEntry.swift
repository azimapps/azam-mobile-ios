//
//  AzamCEOWidgetEntry.swift
//  AzamCEOWidget
//

import WidgetKit
import Foundation

struct AzamCEOWidgetEntry: TimelineEntry {
    let date: Date
    let activeCount: Int
    let nearestDeadlineId: UUID?
    let nearestDeadlineTitle: String?
    let nearestDeadlineDate: Date?
    let nearestDeadlineCategory: WaitCategory?
    let categoryBreakdown: [WaitCategory: Int]

    static let placeholder = AzamCEOWidgetEntry(
        date: .now,
        activeCount: 5,
        nearestDeadlineId: UUID(),
        nearestDeadlineTitle: "Job Application",
        nearestDeadlineDate: Calendar.current.date(byAdding: .day, value: 3, to: .now),
        nearestDeadlineCategory: .job,
        categoryBreakdown: [.job: 2, .product: 1, .admin: 1, .event: 1]
    )

    static let empty = AzamCEOWidgetEntry(
        date: .now,
        activeCount: 0,
        nearestDeadlineId: nil,
        nearestDeadlineTitle: nil,
        nearestDeadlineDate: nil,
        nearestDeadlineCategory: nil,
        categoryBreakdown: [:]
    )
}
