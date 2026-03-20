//
//  TestHelpers.swift
//  AwaitrTests
//

import Foundation
import SwiftData
@testable import Awaitr

// MARK: - Test Container

enum TestContainer {
    @MainActor
    static func make() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: WaitItem.self, configurations: config)
    }
}

// MARK: - WaitItem Factory

enum WaitItemFactory {
    static func make(
        title: String = "Test Item",
        category: WaitCategory = .job,
        status: WaitStatus = .submitted,
        submittedAt: Date = .now,
        priority: WaitPriority = .medium,
        notes: String = "",
        expectedAt: Date? = nil,
        followUpAt: Date? = nil,
        isArchived: Bool = false
    ) -> WaitItem {
        let item = WaitItem(
            title: title,
            category: category,
            submittedAt: submittedAt,
            priority: priority,
            notes: notes,
            expectedAt: expectedAt,
            followUpAt: followUpAt
        )
        // Set status by transitioning through pipeline if needed
        if status != .submitted {
            for transition in transitionPath(to: status) {
                item.transition(to: transition)
            }
        }
        if isArchived && !status.isTerminal {
            item.archive()
        }
        return item
    }

    private static func transitionPath(to target: WaitStatus) -> [WaitStatus] {
        switch target {
        case .submitted: []
        case .inReview: [.inReview]
        case .awaiting: [.inReview, .awaiting]
        case .accepted: [.inReview, .awaiting, .accepted]
        case .rejected: [.rejected]
        }
    }
}
