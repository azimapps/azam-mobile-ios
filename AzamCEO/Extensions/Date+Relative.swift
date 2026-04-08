//
//  Date+Relative.swift
//  AzamCEO
//

import Foundation

extension Date {
    /// Returns a human-readable relative string: "Today", "Yesterday", "3 days ago", or "In 2 days".
    var relativeString: String {
        let calendar = Calendar.current
        let now = Date.now
        let startOfToday = calendar.startOfDay(for: now)
        let startOfDate = calendar.startOfDay(for: self)
        let days = calendar.dateComponents([.day], from: startOfToday, to: startOfDate).day ?? 0

        switch days {
        case 0: return String(localized: "Today")
        case -1: return String(localized: "Yesterday")
        case ..<(-1): return String(localized: "\(abs(days)) days ago")
        case 1: return String(localized: "Tomorrow")
        default: return String(localized: "In \(days) days")
        }
    }

    /// Short formatted date: "Mar 20, 2026"
    var shortFormatted: String {
        formatted(.dateTime.month(.abbreviated).day().year())
    }

    /// Number of days from this date until another date. Negative if target is in the past.
    func daysUntil(_ target: Date) -> Int {
        Calendar.current.dateComponents([.day], from: self, to: target).day ?? 0
    }
}
