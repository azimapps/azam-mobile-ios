//
//  ItemDetailViewModel.swift
//  Awaitr
//

import SwiftUI
import SwiftData

@MainActor @Observable
final class ItemDetailViewModel {
    let item: WaitItem
    private let modelContext: ModelContext

    init(item: WaitItem, modelContext: ModelContext) {
        self.item = item
        self.modelContext = modelContext
    }

    // MARK: - Status Actions

    func advanceStatus() {
        item.advanceStatus()
        if item.status.isTerminal {
            NotificationService.cancel(for: item.id)
        }
    }

    func rejectItem() {
        item.reject()
        NotificationService.cancel(for: item.id)
    }

    // MARK: - Archive

    func archiveItem() {
        item.archive()
        NotificationService.cancel(for: item.id)
    }

    // MARK: - Delete

    func deleteItem() {
        NotificationService.cancel(for: item.id)
        modelContext.delete(item)
    }

    // MARK: - Notes

    func updateNotes(_ newNotes: String) {
        guard WaitItem.validateNotes(newNotes) else { return }
        item.notes = newNotes
        item.updatedAt = .now
    }
}
