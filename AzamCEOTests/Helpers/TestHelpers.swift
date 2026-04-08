//
//  TestHelpers.swift
//  AzamCEOTests
//

import Foundation
import SwiftData
@testable import AzamCEO

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
        template: PipelineTemplate? = nil,
        status: WaitStatus = .pending,
        submittedAt: Date = .now,
        priority: WaitPriority = .medium,
        notes: String = "",
        expectedAt: Date? = nil,
        followUpAt: Date? = nil,
        isArchived: Bool = false
    ) -> WaitItem {
        let resolvedTemplate = template ?? PipelineTemplate.defaultTemplate(for: category)
        let item = WaitItem(
            title: title,
            category: category,
            template: resolvedTemplate,
            submittedAt: submittedAt,
            priority: priority,
            notes: notes,
            expectedAt: expectedAt,
            followUpAt: followUpAt
        )
        // Set status by transitioning through pipeline if needed
        if status != .pending {
            let stages = resolvedTemplate.stages
            if let targetIndex = stages.firstIndex(of: status), targetIndex > 0 {
                for i in 1...targetIndex {
                    item.transition(to: stages[i])
                }
            } else if status.isTerminal {
                item.transition(to: status)
            }
        }
        if isArchived && !status.isTerminal {
            item.archive()
        }
        return item
    }
}
