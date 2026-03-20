//
//  ArchiveViewModel.swift
//  Awaitr
//

import SwiftUI
import SwiftData

@MainActor @Observable
final class ArchiveViewModel {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
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
        items.filter { $0.status == .accepted }.count
    }

    func totalRejected(from items: [WaitItem]) -> Int {
        items.filter { $0.status == .rejected }.count
    }

    func acceptanceRate(from items: [WaitItem]) -> Double {
        let accepted = totalAccepted(from: items)
        let total = accepted + totalRejected(from: items)
        guard total > 0 else { return 0 }
        return Double(accepted) / Double(total)
    }

    // MARK: - Actions

    func unarchiveItem(_ item: WaitItem) {
        item.unarchive()
    }
}
