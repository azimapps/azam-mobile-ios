//
//  ArchiveViewModel.swift
//  AzamCEO
//

import SwiftUI
import SwiftData

@MainActor @Observable
final class ArchiveViewModel {
    var searchText: String = ""

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Filtering

    /// Filters archived items by search text (matches title and notes).
    func filteredItems(from items: [WaitItem]) -> [WaitItem] {
        guard !searchText.isEmpty else { return items }
        let query = searchText.lowercased()
        return items.filter {
            $0.title.lowercased().contains(query) ||
            $0.notes.lowercased().contains(query)
        }
    }

    // MARK: - Grouping

    /// Groups archived items by month (e.g., "March 2026"), sorted reverse-chronologically.
    func groupedByMonth(from items: [WaitItem]) -> [(key: String, items: [WaitItem])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let grouped = Dictionary(grouping: items) { item in
            formatter.string(from: item.updatedAt)
        }

        return grouped
            .map { (key: $0.key, items: $0.value) }
            .sorted { lhs, rhs in
                guard let lhsDate = lhs.items.first?.updatedAt,
                      let rhsDate = rhs.items.first?.updatedAt else { return false }
                return lhsDate > rhsDate
            }
    }

    // MARK: - Stats

    func totalAccepted(from items: [WaitItem]) -> Int {
        items.filter { $0.status == .positive }.count
    }

    func totalRejected(from items: [WaitItem]) -> Int {
        items.filter { $0.status == .negative }.count
    }

    func acceptanceRate(from items: [WaitItem]) -> Double {
        let accepted = totalAccepted(from: items)
        let total = accepted + totalRejected(from: items)
        guard total > 0 else { return 0 }
        return Double(accepted) / Double(total)
    }

    // MARK: - Chart Data

    /// Counts archived items per category.
    func categoryBreakdown(from items: [WaitItem]) -> [(category: WaitCategory, count: Int)] {
        WaitCategory.allCases.compactMap { category in
            let count = items.filter { $0.category == category }.count
            return count > 0 ? (category: category, count: count) : nil
        }
    }

    /// Accepted vs rejected counts grouped by month (last 6 months).
    func monthlyTrends(from items: [WaitItem]) -> [(month: String, date: Date, accepted: Int, rejected: Int)] {
        let calendar = Calendar.current
        let now = Date.now
        let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) ?? now

        let recentItems = items.filter { $0.updatedAt >= sixMonthsAgo }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        let grouped = Dictionary(grouping: recentItems) { item in
            calendar.dateComponents([.year, .month], from: item.updatedAt)
        }

        return grouped
            .compactMap { (components, groupItems) -> (month: String, date: Date, accepted: Int, rejected: Int)? in
                guard let date = calendar.date(from: components) else { return nil }
                return (
                    month: formatter.string(from: date),
                    date: date,
                    accepted: groupItems.filter { $0.status == .positive }.count,
                    rejected: groupItems.filter { $0.status == .negative }.count
                )
            }
            .sorted { $0.date < $1.date }
    }

    /// Average days waited per category (terminal items only).
    func averageWaitTime(from items: [WaitItem]) -> [(category: WaitCategory, avgDays: Double)] {
        WaitCategory.allCases.compactMap { category in
            let categoryItems = items.filter {
                $0.category == category && $0.status.isTerminal
            }
            guard !categoryItems.isEmpty else { return nil }

            let totalDays = categoryItems.reduce(0.0) { sum, item in
                let endDate = item.statusHistory.last?.timestamp ?? item.updatedAt
                return sum + endDate.timeIntervalSince(item.submittedAt) / 86400
            }
            let avg = totalDays / Double(categoryItems.count)
            return (category: category, avgDays: avg)
        }
    }

    // MARK: - Actions

    func unarchiveItem(_ item: WaitItem) {
        item.unarchive()
    }
}
