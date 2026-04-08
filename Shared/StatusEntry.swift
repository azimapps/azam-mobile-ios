//
//  StatusEntry.swift
//  AzamCEO
//

import Foundation

/// A single entry in a WaitItem's status history timeline.
/// Stored as a Codable struct (NOT a @Model) — serialized as JSON array in WaitItem.
struct StatusEntry: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let status: WaitStatus
    let timestamp: Date

    init(status: WaitStatus, timestamp: Date = .now) {
        self.id = UUID()
        self.status = status
        self.timestamp = timestamp
    }
}
