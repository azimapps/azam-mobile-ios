//
//  DashboardViewModelTests.swift
//  AwaitrTests
//

import Testing
import Foundation
import SwiftData
@testable import Awaitr

@MainActor
struct DashboardViewModelTests {

    private func makeVM() throws -> (DashboardViewModel, ModelContext) {
        let container = try TestContainer.make()
        let context = container.mainContext
        let vm = DashboardViewModel(modelContext: context)
        return (vm, context)
    }

    // MARK: - Filtering

    @Test func filteredItemsReturnsAllWhenNoFilter() throws {
        let (vm, _) = try makeVM()
        let items = [
            WaitItemFactory.make(title: "A", category: .job),
            WaitItemFactory.make(title: "B", category: .admin),
        ]
        let result = vm.filteredItems(from: items)
        #expect(result.count == 2)
    }

    @Test func filteredItemsByCategoryFilter() throws {
        let (vm, _) = try makeVM()
        vm.selectedCategory = .job
        let items = [
            WaitItemFactory.make(title: "A", category: .job),
            WaitItemFactory.make(title: "B", category: .admin),
            WaitItemFactory.make(title: "C", category: .job),
        ]
        let result = vm.filteredItems(from: items)
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.category == .job })
    }

    @Test func filteredItemsBySearchText() throws {
        let (vm, _) = try makeVM()
        vm.searchText = "apple"
        let items = [
            WaitItemFactory.make(title: "Apple Engineer"),
            WaitItemFactory.make(title: "Google Developer"),
        ]
        let result = vm.filteredItems(from: items)
        #expect(result.count == 1)
        #expect(result.first?.title == "Apple Engineer")
    }

    @Test func filteredItemsSortsByPriorityThenDate() throws {
        let (vm, _) = try makeVM()
        let old = Calendar.current.date(byAdding: .day, value: -10, to: .now)!
        let items = [
            WaitItemFactory.make(title: "Low", submittedAt: .now, priority: .low),
            WaitItemFactory.make(title: "High Old", submittedAt: old, priority: .high),
            WaitItemFactory.make(title: "High New", submittedAt: .now, priority: .high),
        ]
        let result = vm.filteredItems(from: items)
        #expect(result[0].title == "High Old")
        #expect(result[1].title == "High New")
        #expect(result[2].title == "Low")
    }

    // MARK: - Category Counts

    @Test func categoryCountsReturnsCorrectCounts() throws {
        let (vm, _) = try makeVM()
        let items = [
            WaitItemFactory.make(category: .job),
            WaitItemFactory.make(category: .job),
            WaitItemFactory.make(category: .admin),
        ]
        let counts = vm.categoryCounts(from: items)
        #expect(counts[.job] == 2)
        #expect(counts[.admin] == 1)
        #expect(counts[.product] == 0)
        #expect(counts[.event] == 0)
    }
}
