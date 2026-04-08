//
//  StatusTransitionTests.swift
//  AzamCEOTests
//

import Testing
import Foundation
@testable import AzamCEO

@MainActor
struct StatusTransitionTests {

    // MARK: - Job Application (3-stage pipeline)

    @Test func advanceJobFromPending() {
        let item = WaitItem(title: "Test", category: .job, template: .jobApplication)
        item.advanceStatus()
        #expect(item.status == .active)
        #expect(item.statusHistory.count == 2)
    }

    @Test func advanceJobFromActive() {
        let item = WaitItem(title: "Test", category: .job, template: .jobApplication)
        item.advanceStatus() // → active
        item.advanceStatus() // → finalReview
        #expect(item.status == .finalReview)
        #expect(item.statusHistory.count == 3)
    }

    @Test func advanceJobFromFinalReviewIsNoop() {
        let item = WaitItem(title: "Test", category: .job, template: .jobApplication)
        item.advanceStatus() // → active
        item.advanceStatus() // → finalReview
        item.advanceStatus() // noop
        #expect(item.status == .finalReview)
        #expect(item.statusHistory.count == 3)
    }

    @Test func advanceFromTerminalIsNoop() {
        let item = WaitItem(title: "Test", category: .job, template: .jobApplication)
        item.transition(to: .positive)
        let historyCount = item.statusHistory.count
        item.advanceStatus() // noop
        #expect(item.status == .positive)
        #expect(item.statusHistory.count == historyCount)
    }

    // MARK: - Document (2-stage pipeline)

    @Test func advanceDocFromPending() {
        let item = WaitItem(title: "Test", category: .admin, template: .document)
        item.advanceStatus() // → active
        #expect(item.status == .active)
    }

    @Test func advanceDocFromActiveIsNoop() {
        let item = WaitItem(title: "Test", category: .admin, template: .document)
        item.advanceStatus() // → active
        item.advanceStatus() // noop
        #expect(item.status == .active)
        #expect(item.statusHistory.count == 2)
    }

    @Test func docCannotReachFinalReview() {
        let item = WaitItem(title: "Test", category: .admin, template: .document)
        item.advanceStatus() // → active
        item.transition(to: .finalReview) // invalid
        #expect(item.status == .active)
    }

    // MARK: - Event Registration (1-stage pipeline)

    @Test func eventRegistrationAdvanceIsNoop() {
        let item = WaitItem(title: "Test", category: .event, template: .eventRegistration)
        item.advanceStatus() // noop — only 1 stage
        #expect(item.status == .pending)
        #expect(item.statusHistory.count == 1)
    }

    @Test func eventRegistrationCanResolve() {
        let item = WaitItem(title: "Test", category: .event, template: .eventRegistration)
        item.transition(to: .positive)
        #expect(item.status == .positive)
        #expect(item.isArchived)
    }

    // MARK: - Direct Transitions

    @Test func transitionToValidStatus() {
        let item = WaitItem(title: "Test", category: .job, template: .jobApplication)
        item.transition(to: .active)
        #expect(item.status == .active)
    }

    @Test func transitionToInvalidStatusIsNoop() {
        let item = WaitItem(title: "Test", category: .job, template: .jobApplication)
        item.transition(to: .finalReview) // invalid: must go through active
        #expect(item.status == .pending)
    }

    @Test func transitionToPositiveAutoArchives() {
        let item = WaitItem(title: "Test", category: .job, template: .jobApplication)
        item.transition(to: .positive)
        #expect(item.isArchived)
    }

    @Test func transitionToNegativeAutoArchives() {
        let item = WaitItem(title: "Test", category: .job, template: .jobApplication)
        item.transition(to: .negative)
        #expect(item.isArchived)
    }

    // MARK: - Reject Shortcut

    @Test func rejectFromPending() {
        let item = WaitItem(title: "Test", category: .job, template: .jobApplication)
        item.reject()
        #expect(item.status == .negative)
        #expect(item.isArchived)
    }

    @Test func rejectFromActive() {
        let item = WaitItem(title: "Test", category: .job, template: .jobApplication)
        item.advanceStatus() // → active
        item.reject()
        #expect(item.status == .negative)
    }

    // MARK: - Status History Logging

    @Test func statusHistoryLogsAllTransitions() {
        let item = WaitItem(title: "Test", category: .job, template: .jobApplication)
        item.advanceStatus() // → active
        item.advanceStatus() // → finalReview
        item.transition(to: .positive) // → positive

        #expect(item.statusHistory.count == 4)
        #expect(item.statusHistory[0].status == .pending)
        #expect(item.statusHistory[1].status == .active)
        #expect(item.statusHistory[2].status == .finalReview)
        #expect(item.statusHistory[3].status == .positive)
    }

    @Test func updatedAtChangesOnTransition() {
        let item = WaitItem(title: "Test", category: .job, template: .jobApplication)
        let original = item.updatedAt
        item.advanceStatus()
        #expect(item.updatedAt >= original)
    }

    // MARK: - Skip to Terminal from Any Stage

    @Test func skipToPositiveFromPending() {
        let item = WaitItem(title: "Test", category: .job, template: .jobApplication)
        item.transition(to: .positive)
        #expect(item.status == .positive)
        #expect(item.isArchived)
    }

    @Test func skipToNegativeFromActive() {
        let item = WaitItem(title: "Test", category: .product, template: .preOrder)
        item.advanceStatus() // → active
        item.transition(to: .negative)
        #expect(item.status == .negative)
        #expect(item.isArchived)
    }
}
