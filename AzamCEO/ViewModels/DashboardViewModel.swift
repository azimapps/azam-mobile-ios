//
//  DashboardViewModel.swift
//  AzamCEO
//

import SwiftUI
import SwiftData
import WidgetKit

@MainActor @Observable
final class DashboardViewModel {
    var selectedCategory: WaitCategory?
    var searchText: String = ""
    var selectedStatuses: Set<WaitStatus> = []
    var selectedPriorities: Set<WaitPriority> = []

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Filter State

    var activeFilterCount: Int {
        selectedStatuses.count + selectedPriorities.count
    }

    var hasActiveFilters: Bool {
        activeFilterCount > 0
    }

    func clearAllFilters() {
        selectedStatuses.removeAll()
        selectedPriorities.removeAll()
    }

    // MARK: - Filtering

    /// Filters items by category, search text, status, and priority.
    /// Items come from View's @Query — ViewModel only does in-memory filtering.
    func filteredItems(from items: [WaitItem]) -> [WaitItem] {
        var result = items

        if let selectedCategory {
            result = result.filter { $0.category == selectedCategory }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.notes.lowercased().contains(query)
            }
        }

        if !selectedStatuses.isEmpty {
            result = result.filter { selectedStatuses.contains($0.status) }
        }

        if !selectedPriorities.isEmpty {
            result = result.filter { selectedPriorities.contains($0.priority) }
        }

        return result.sorted { lhs, rhs in
            if lhs.priority.sortOrder != rhs.priority.sortOrder {
                return lhs.priority.sortOrder < rhs.priority.sortOrder
            }
            return lhs.submittedAt < rhs.submittedAt
        }
    }

    /// Returns count of active items per category.
    func categoryCounts(from items: [WaitItem]) -> [WaitCategory: Int] {
        var counts: [WaitCategory: Int] = [:]
        for category in WaitCategory.allCases {
            counts[category] = items.filter { $0.category == category }.count
        }
        return counts
    }

    // MARK: - Actions

    func deleteItem(_ item: WaitItem) {
        NotificationService.cancel(for: item.id)
        modelContext.delete(item)
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
