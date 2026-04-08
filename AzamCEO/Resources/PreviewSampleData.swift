//
//  PreviewSampleData.swift
//  AzamCEO
//

import SwiftData
import Foundation

// MARK: - Preview Container

@MainActor
func previewContainer() -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WaitItem.self, configurations: config)

    for item in PreviewSampleData.items {
        container.mainContext.insert(item)
    }

    return container
}

// MARK: - Sample Data

enum PreviewSampleData {
    @MainActor
    static let items: [WaitItem] = [
        // Jobs
        makeItem("Apple — iOS Engineer", .job, .jobApplication, .active, .high, daysAgo: 14, expected: 30),
        makeItem("Google — SWE III", .job, .jobApplication, .pending, .high, daysAgo: 7, expected: 45),
        makeItem("Stripe — Mobile Developer", .job, .jobApplication, .finalReview, .medium, daysAgo: 21, expected: 10),
        makeItem("Netflix — Senior iOS", .job, .jobApplication, .positive, .high, daysAgo: 30, archived: true),
        makeItem("Meta — Software Engineer", .job, .scholarship, .negative, .medium, daysAgo: 25, archived: true),

        // Products
        makeItem("iPhone 18 Pro Max", .product, .preOrder, .pending, .low, daysAgo: 3, expected: 60),
        makeItem("AirPods Pro 4", .product, .preOrder, .active, .medium, daysAgo: 10),
        makeItem("Steam Deck 2", .product, .productWaitlist, .pending, .low, daysAgo: 45, expected: 90),

        // Admin
        makeItem("Passport Renewal", .admin, .document, .active, .high, daysAgo: 28, expected: 14),
        makeItem("Tax Refund 2025", .admin, .document, .positive, .medium, daysAgo: 60, archived: true),
        makeItem("Building Permit", .admin, .permit, .active, .low, daysAgo: 90),

        // Events
        makeItem("WWDC 2026 Scholarship", .event, .eventWaitlist, .pending, .high, daysAgo: 5, expected: 30),
        makeItem("Local Meetup Speaker", .event, .eventRegistration, .positive, .medium, daysAgo: 15, archived: true),
        makeItem("Conference Early Bird", .event, .eventRegistration, .pending, .low, daysAgo: 2, expected: 14),
    ]

    @MainActor
    private static func makeItem(
        _ title: String,
        _ category: WaitCategory,
        _ template: PipelineTemplate,
        _ status: WaitStatus,
        _ priority: WaitPriority,
        daysAgo: Int,
        expected: Int? = nil,
        archived: Bool = false
    ) -> WaitItem {
        let submitted = Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now
        let expectedDate = expected.flatMap {
            Calendar.current.date(byAdding: .day, value: $0, to: submitted)
        }

        let item = WaitItem(
            title: title,
            category: category,
            template: template,
            submittedAt: submitted,
            priority: priority,
            expectedAt: expectedDate
        )

        // Transition to target status using template-aware pipeline
        let stages = template.stages
        if let targetIndex = stages.firstIndex(of: status) {
            for i in 1...targetIndex {
                item.transition(to: stages[i])
            }
        } else if status.isTerminal {
            // For terminal statuses, advance through all stages first, then transition
            for i in 1..<stages.count {
                item.transition(to: stages[i])
            }
            item.transition(to: status)
        }

        if archived && !item.isArchived {
            item.archive()
        }

        return item
    }
}
