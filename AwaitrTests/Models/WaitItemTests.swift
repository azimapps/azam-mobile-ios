//
//  WaitItemTests.swift
//  AwaitrTests
//

import Testing
import Foundation
import SwiftData
@testable import Awaitr

@MainActor
struct WaitItemTests {

    // MARK: - Initialization

    @Test func initSetsDefaults() {
        let item = WaitItem(title: "Test", category: .job)

        #expect(item.title == "Test")
        #expect(item.category == .job)
        #expect(item.status == .submitted)
        #expect(item.priority == .medium)
        #expect(item.notes.isEmpty)
        #expect(item.isArchived == false)
        #expect(item.statusHistory.count == 1)
        #expect(item.statusHistory.first?.status == .submitted)
    }

    @Test func initWithAllParameters() {
        let date = Date.now
        let expected = Calendar.current.date(byAdding: .day, value: 30, to: date)!
        let item = WaitItem(
            title: "Full Item",
            category: .admin,
            submittedAt: date,
            priority: .high,
            notes: "Some notes",
            expectedAt: expected
        )

        #expect(item.category == .admin)
        #expect(item.priority == .high)
        #expect(item.notes == "Some notes")
        #expect(item.expectedAt == expected)
    }

    // MARK: - Days Waiting

    @Test func daysWaitingCalculation() {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: .now)!
        let item = WaitItem(title: "Test", category: .job, submittedAt: threeDaysAgo)

        #expect(item.daysWaiting == 3)
    }

    @Test func daysWaitingLabelToday() {
        let item = WaitItem(title: "Test", category: .job, submittedAt: .now)
        #expect(item.daysWaitingLabel == "Today")
    }

    @Test func daysWaitingLabelOneDay() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        let item = WaitItem(title: "Test", category: .job, submittedAt: yesterday)
        #expect(item.daysWaitingLabel == "1 day")
    }

    @Test func daysWaitingLabelMultipleDays() {
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: .now)!
        let item = WaitItem(title: "Test", category: .job, submittedAt: fiveDaysAgo)
        #expect(item.daysWaitingLabel == "5 days")
    }

    // MARK: - Overdue

    @Test func isOverdueWhenPastExpected() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        let item = WaitItem(title: "Test", category: .job, expectedAt: pastDate)
        #expect(item.isOverdue)
    }

    @Test func notOverdueWhenNoExpectedDate() {
        let item = WaitItem(title: "Test", category: .job)
        #expect(!item.isOverdue)
    }

    @Test func notOverdueWhenTerminal() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        let item = WaitItem(title: "Test", category: .job, expectedAt: pastDate)
        item.transition(to: .accepted)
        #expect(!item.isOverdue)
    }

    // MARK: - Archive

    @Test func archiveSetsFlag() {
        let item = WaitItem(title: "Test", category: .job)
        item.archive()
        #expect(item.isArchived)
    }

    @Test func unarchiveClearsFlag() {
        let item = WaitItem(title: "Test", category: .job)
        item.archive()
        item.unarchive()
        #expect(!item.isArchived)
    }

    // MARK: - Validation

    @Test func validateTitleAcceptsValid() {
        #expect(WaitItem.validateTitle("Valid Title"))
        #expect(WaitItem.validateTitle(String(repeating: "a", count: 80)))
    }

    @Test func validateTitleRejectsInvalid() {
        #expect(!WaitItem.validateTitle(""))
        #expect(!WaitItem.validateTitle("   "))
        #expect(!WaitItem.validateTitle(String(repeating: "a", count: 81)))
    }

    @Test func validateNotesAcceptsValid() {
        #expect(WaitItem.validateNotes(""))
        #expect(WaitItem.validateNotes("Some notes"))
        #expect(WaitItem.validateNotes(String(repeating: "a", count: 500)))
    }

    @Test func validateNotesRejectsOverLimit() {
        #expect(!WaitItem.validateNotes(String(repeating: "a", count: 501)))
    }

    // MARK: - Latest Status Entry

    @Test func latestStatusEntryReturnsLast() {
        let item = WaitItem(title: "Test", category: .job)
        #expect(item.latestStatusEntry?.status == .submitted)

        item.transition(to: .inReview)
        #expect(item.latestStatusEntry?.status == .inReview)
    }
}
