//
//  AddEditViewModel.swift
//  Awaitr
//

import SwiftUI
import SwiftData

@MainActor @Observable
final class AddEditViewModel {
    // MARK: - Form State

    var title: String = ""
    var category: WaitCategory = .job
    var submittedAt: Date = .now
    var expectedAt: Date?
    var followUpAt: Date?
    var priority: WaitPriority = .medium
    var notes: String = ""

    var hasExpectedDate: Bool = false
    var hasFollowUpDate: Bool = false

    // MARK: - Internal

    private let modelContext: ModelContext
    private let existingItem: WaitItem?
    private let originalTitle: String
    private let originalCategory: WaitCategory
    private let originalNotes: String

    /// Create mode.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.existingItem = nil
        self.originalTitle = ""
        self.originalCategory = .job
        self.originalNotes = ""
    }

    /// Edit mode.
    init(item: WaitItem, modelContext: ModelContext) {
        self.modelContext = modelContext
        self.existingItem = item

        self.title = item.title
        self.category = item.category
        self.submittedAt = item.submittedAt
        self.expectedAt = item.expectedAt
        self.followUpAt = item.followUpAt
        self.priority = item.priority
        self.notes = item.notes
        self.hasExpectedDate = item.expectedAt != nil
        self.hasFollowUpDate = item.followUpAt != nil

        self.originalTitle = item.title
        self.originalCategory = item.category
        self.originalNotes = item.notes
    }

    // MARK: - Validation

    var isEditing: Bool { existingItem != nil }

    var isValid: Bool {
        WaitItem.validateTitle(title) && WaitItem.validateNotes(notes)
    }

    var hasChanges: Bool {
        guard let item = existingItem else { return true }
        return title != item.title
            || category != item.category
            || submittedAt != item.submittedAt
            || expectedAt != item.expectedAt
            || followUpAt != item.followUpAt
            || priority != item.priority
            || notes != item.notes
    }

    var titleCharacterCount: Int { title.count }
    var notesCharacterCount: Int { notes.count }

    // MARK: - Save

    func save() async {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedExpectedAt = hasExpectedDate ? expectedAt : nil
        let resolvedFollowUpAt = hasFollowUpDate ? followUpAt : nil

        if let item = existingItem {
            // Edit existing
            item.title = trimmedTitle
            item.category = category
            item.submittedAt = submittedAt
            item.expectedAt = resolvedExpectedAt
            item.followUpAt = resolvedFollowUpAt
            item.priority = priority
            item.notes = notes
            item.updatedAt = .now

            // Reschedule notification
            NotificationService.cancel(for: item.id)
            if let followUp = resolvedFollowUpAt {
                await NotificationService.scheduleFollowUp(
                    for: item.id, title: trimmedTitle, category: category, at: followUp
                )
                item.notificationId = NotificationService.notificationId(for: item.id)
            } else {
                item.notificationId = nil
            }
        } else {
            // Create new
            let newItem = WaitItem(
                title: trimmedTitle,
                category: category,
                submittedAt: submittedAt,
                priority: priority,
                notes: notes,
                expectedAt: resolvedExpectedAt,
                followUpAt: resolvedFollowUpAt
            )

            if let followUp = resolvedFollowUpAt {
                await NotificationService.scheduleFollowUp(
                    for: newItem.id, title: trimmedTitle, category: category, at: followUp
                )
                newItem.notificationId = NotificationService.notificationId(for: newItem.id)
            }

            modelContext.insert(newItem)
        }
    }
}
