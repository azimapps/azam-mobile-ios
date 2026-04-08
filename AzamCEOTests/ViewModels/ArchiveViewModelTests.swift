//
//  ArchiveViewModelTests.swift
//  AzamCEOTests
//

import Testing
import Foundation
import SwiftData
@testable import AzamCEO

@MainActor
struct ArchiveViewModelTests {

    private func makeVM() throws -> ArchiveViewModel {
        let container = try TestContainer.make()
        return ArchiveViewModel(modelContext: container.mainContext)
    }

    // MARK: - Stats

    @Test func totalAcceptedCounts() throws {
        let vm = try makeVM()
        let items = [
            WaitItemFactory.make(status: .positive, isArchived: true),
            WaitItemFactory.make(status: .negative, isArchived: true),
            WaitItemFactory.make(status: .positive, isArchived: true),
        ]
        #expect(vm.totalAccepted(from: items) == 2)
    }

    @Test func totalRejectedCounts() throws {
        let vm = try makeVM()
        let items = [
            WaitItemFactory.make(status: .positive, isArchived: true),
            WaitItemFactory.make(status: .negative, isArchived: true),
        ]
        #expect(vm.totalRejected(from: items) == 1)
    }

    @Test func acceptanceRateCalculation() throws {
        let vm = try makeVM()
        let items = [
            WaitItemFactory.make(status: .positive, isArchived: true),
            WaitItemFactory.make(status: .positive, isArchived: true),
            WaitItemFactory.make(status: .negative, isArchived: true),
        ]
        let rate = vm.acceptanceRate(from: items)
        #expect(abs(rate - 2.0/3.0) < 0.01)
    }

    @Test func acceptanceRateZeroWhenNoItems() throws {
        let vm = try makeVM()
        #expect(vm.acceptanceRate(from: []) == 0)
    }

    // MARK: - Unarchive

    @Test func unarchiveRestoresItem() throws {
        let vm = try makeVM()
        let item = WaitItemFactory.make(status: .positive, isArchived: true)
        vm.unarchiveItem(item)
        #expect(!item.isArchived)
    }
}
