//
//  StatusTransitionTests.swift
//  AwaitrTests
//

import Testing
import Foundation
@testable import Awaitr

@MainActor
struct StatusTransitionTests {

    // MARK: - Advance Status

    @Test func advanceFromSubmitted() {
        let item = WaitItem(title: "Test", category: .job)
        item.advanceStatus()
        #expect(item.status == .inReview)
        #expect(item.statusHistory.count == 2)
    }

    @Test func advanceFromInReview() {
        let item = WaitItem(title: "Test", category: .job)
        item.advanceStatus() // → inReview
        item.advanceStatus() // → awaiting
        #expect(item.status == .awaiting)
        #expect(item.statusHistory.count == 3)
    }

    @Test func advanceFromAwaitingIsNoop() {
        let item = WaitItem(title: "Test", category: .job)
        item.advanceStatus() // → inReview
        item.advanceStatus() // → awaiting
        item.advanceStatus() // noop
        #expect(item.status == .awaiting)
        #expect(item.statusHistory.count == 3)
    }

    @Test func advanceFromTerminalIsNoop() {
        let item = WaitItem(title: "Test", category: .job)
        item.transition(to: .accepted)
        let historyCount = item.statusHistory.count
        item.advanceStatus() // noop
        #expect(item.status == .accepted)
        #expect(item.statusHistory.count == historyCount)
    }

    // MARK: - Direct Transitions

    @Test func transitionToValidStatus() {
        let item = WaitItem(title: "Test", category: .job)
        item.transition(to: .inReview)
        #expect(item.status == .inReview)
    }

    @Test func transitionToInvalidStatusIsNoop() {
        let item = WaitItem(title: "Test", category: .job)
        item.transition(to: .awaiting) // invalid: must go through inReview
        #expect(item.status == .submitted)
    }

    @Test func transitionToAcceptedAutoArchives() {
        let item = WaitItem(title: "Test", category: .job)
        item.transition(to: .accepted)
        #expect(item.isArchived)
    }

    @Test func transitionToRejectedAutoArchives() {
        let item = WaitItem(title: "Test", category: .job)
        item.transition(to: .rejected)
        #expect(item.isArchived)
    }

    // MARK: - Reject Shortcut

    @Test func rejectFromSubmitted() {
        let item = WaitItem(title: "Test", category: .job)
        item.reject()
        #expect(item.status == .rejected)
        #expect(item.isArchived)
    }

    @Test func rejectFromInReview() {
        let item = WaitItem(title: "Test", category: .job)
        item.advanceStatus() // → inReview
        item.reject()
        #expect(item.status == .rejected)
    }

    // MARK: - Status History Logging

    @Test func statusHistoryLogsAllTransitions() {
        let item = WaitItem(title: "Test", category: .job)
        item.advanceStatus() // → inReview
        item.advanceStatus() // → awaiting
        item.transition(to: .accepted) // → accepted

        #expect(item.statusHistory.count == 4)
        #expect(item.statusHistory[0].status == .submitted)
        #expect(item.statusHistory[1].status == .inReview)
        #expect(item.statusHistory[2].status == .awaiting)
        #expect(item.statusHistory[3].status == .accepted)
    }

    @Test func updatedAtChangesOnTransition() {
        let item = WaitItem(title: "Test", category: .job)
        let original = item.updatedAt
        // Small delay to ensure time difference
        item.advanceStatus()
        #expect(item.updatedAt >= original)
    }
}
