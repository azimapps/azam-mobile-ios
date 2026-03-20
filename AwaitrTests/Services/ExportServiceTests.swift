//
//  ExportServiceTests.swift
//  AwaitrTests
//

import Testing
import Foundation
@testable import Awaitr

@MainActor
struct ExportServiceTests {

    @Test func csvHasHeader() {
        let csv = ExportService.generateCSV(from: [])
        #expect(csv.starts(with: "Title,Category,Status,Priority,Submitted,Expected,Follow-up,Notes,Archived,Days Waiting"))
    }

    @Test func csvHasCorrectRowCount() {
        let items = [
            WaitItemFactory.make(title: "Item 1"),
            WaitItemFactory.make(title: "Item 2"),
        ]
        let csv = ExportService.generateCSV(from: items)
        let lines = csv.components(separatedBy: "\n")
        #expect(lines.count == 3) // header + 2 rows
    }

    @Test func csvContainsItemData() {
        let item = WaitItemFactory.make(title: "Apple Job", category: .job, priority: .high)
        let csv = ExportService.generateCSV(from: [item])
        #expect(csv.contains("Apple Job"))
        #expect(csv.contains("Job"))
        #expect(csv.contains("High"))
    }

    @Test func csvEscapesCommasInValues() {
        let item = WaitItemFactory.make(title: "Job, at Apple", notes: "Important, urgent")
        let csv = ExportService.generateCSV(from: [item])
        #expect(csv.contains("\"Job, at Apple\""))
    }

    @Test func csvEscapesQuotesInValues() {
        let item = WaitItemFactory.make(notes: "Said \"hello\" there")
        let csv = ExportService.generateCSV(from: [item])
        #expect(csv.contains("\"Said \"\"hello\"\" there\""))
    }

    @Test func csvShowsArchivedStatus() {
        let archived = WaitItemFactory.make(isArchived: true)
        let active = WaitItemFactory.make()
        let csv = ExportService.generateCSV(from: [archived, active])
        let lines = csv.components(separatedBy: "\n")
        #expect(lines[1].contains("Yes"))
        #expect(lines[2].contains("No"))
    }
}
