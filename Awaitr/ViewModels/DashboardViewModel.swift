//
//  DashboardViewModel.swift
//  Awaitr
//

import SwiftUI
import SwiftData

@MainActor @Observable
final class DashboardViewModel {
    var selectedCategory: WaitCategory?
    var searchText: String = ""

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Filtering

    /// Filters items by selected category and search text.
    /// Items come from View's @Query — ViewModel only does in-memory filtering.
    func filteredItems(from items: [WaitItem]) -> [WaitItem] {
        var result = items

        if let selectedCategory {
            result = result.filter { $0.category == selectedCategory }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { $0.title.lowercased().contains(query) }
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
    }
}
