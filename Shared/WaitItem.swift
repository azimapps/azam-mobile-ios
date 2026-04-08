//
//  WaitItem.swift
//  AzamCEO
//

import Foundation
import SwiftData

@Model
final class WaitItem {
    var id: UUID
    var title: String
    var category: WaitCategory
    var status: WaitStatus
    private var _template: PipelineTemplate?

    var template: PipelineTemplate {
        get { _template ?? PipelineTemplate.defaultTemplate(for: category) }
        set { _template = newValue }
    }
    var submittedAt: Date
    var expectedAt: Date?
    var followUpAt: Date?
    var notificationId: String?
    var priority: WaitPriority
    var notes: String
    var statusHistory: [StatusEntry]
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool

    init(
        title: String,
        category: WaitCategory,
        template: PipelineTemplate? = nil,
        submittedAt: Date = .now,
        priority: WaitPriority = .medium,
        notes: String = "",
        expectedAt: Date? = nil,
        followUpAt: Date? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.category = category
        self._template = template ?? PipelineTemplate.defaultTemplate(for: category)
        self.status = .pending
        self.submittedAt = submittedAt
        self.priority = priority
        self.notes = notes
        self.expectedAt = expectedAt
        self.followUpAt = followUpAt
        self.statusHistory = [StatusEntry(status: .pending, timestamp: .now)]
        self.createdAt = .now
        self.updatedAt = .now
        self.isArchived = false
    }

    // MARK: - Computed Properties

    var daysWaiting: Int {
        Calendar.current.dateComponents([.day], from: submittedAt, to: .now).day ?? 0
    }

    var isOverdue: Bool {
        guard let expectedAt else { return false }
        return expectedAt < .now && !status.isTerminal
    }

    var latestStatusEntry: StatusEntry? {
        statusHistory.last
    }

    var daysWaitingLabel: String {
        let days = daysWaiting
        switch days {
        case 0: return String(localized: "Today")
        case 1: return String(localized: "1 day")
        default: return String(localized: "\(days) days")
        }
    }

    // MARK: - Status Transitions

    /// Advance to the next pipeline status. No-op if terminal or at end of pipeline.
    func advanceStatus() {
        guard let next = template.nextStatus(after: status) else { return }
        transition(to: next)
    }

    /// Transition to a specific status if it's a valid transition.
    func transition(to newStatus: WaitStatus) {
        guard template.validTransitions(from: status).contains(newStatus) else { return }
        status = newStatus
        statusHistory.append(StatusEntry(status: newStatus, timestamp: .now))
        updatedAt = .now

        if newStatus.isTerminal {
            archive()
        }
    }

    /// Reject the item (shortcut for transition to negative).
    func reject() {
        transition(to: .negative)
    }

    /// Move item to archive.
    func archive() {
        isArchived = true
        updatedAt = .now
    }

    /// Restore item from archive.
    func unarchive() {
        isArchived = false
        updatedAt = .now
    }

    // MARK: - Validation

    static func validateTitle(_ title: String) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 80
    }

    static func validateNotes(_ notes: String) -> Bool {
        notes.count <= 500
    }

    // MARK: - Predicates

    static var activePredicate: Predicate<WaitItem> {
        #Predicate<WaitItem> { !$0.isArchived }
    }

    static var archivedPredicate: Predicate<WaitItem> {
        #Predicate<WaitItem> { $0.isArchived }
    }

    static func activePredicate(category: WaitCategory) -> Predicate<WaitItem> {
        let rawValue = category.rawValue
        return #Predicate<WaitItem> { !$0.isArchived && $0.category.rawValue == rawValue }
    }
}
