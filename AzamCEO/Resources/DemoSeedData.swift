//
//  DemoSeedData.swift
//  AzamCEO
//
//  Realistic demo data for screenshots. Only included in DEBUG builds.
//

#if DEBUG
import Foundation

enum DemoSeedData {

    @MainActor
    static var allItems: [WaitItem] {
        activeItems + archivedItems
    }

    // MARK: - Active Items (visible on Home)

    @MainActor
    private static var activeItems: [WaitItem] {
        [
            // Jobs — mixed templates and stages
            make("Senior iOS Developer — Apple", .job, .jobApplication, .active, .high,
                 daysAgo: 12, expected: 21, transitionDaysAgo: [12, 6],
                 notes: "Passed phone screen. On-site scheduled next week."),

            make("Google — SWE III", .job, .jobApplication, .pending, .high,
                 daysAgo: 5, expected: 45, transitionDaysAgo: [5],
                 notes: "Applied via referral from college friend."),

            make("Tokopedia — Mobile Engineer", .job, .jobApplication, .finalReview, .medium,
                 daysAgo: 28, expected: 7, transitionDaysAgo: [28, 18, 8],
                 notes: "Offer negotiation stage. Waiting for final package."),

            make("LPDP Scholarship 2026", .job, .scholarship, .active, .high,
                 daysAgo: 18, expected: 60, transitionDaysAgo: [18, 10],
                 notes: "Essay submitted. Interview round pending."),

            // Products — pre-orders and waitlists
            make("iPhone 17 Pro — Pre-order", .product, .preOrder, .active, .medium,
                 daysAgo: 8, expected: 14, transitionDaysAgo: [8, 3]),

            make("PS5 Pro Bundle", .product, .preOrder, .pending, .low,
                 daysAgo: 3, expected: 30, transitionDaysAgo: [3]),

            make("Nothing Phone 3 Waitlist", .product, .productWaitlist, .pending, .low,
                 daysAgo: 22, expected: 45, transitionDaysAgo: [22]),

            // Admin — documents and permits
            make("Passport Renewal — Imigrasi", .admin, .document, .active, .high,
                 daysAgo: 30, expected: 14, transitionDaysAgo: [30, 15],
                 notes: "Biometric done. Waiting for printing."),

            make("Tax Refund 2025", .admin, .document, .pending, .medium,
                 daysAgo: 45, expected: 30, transitionDaysAgo: [45]),

            make("Building Permit — Rumah Ambon", .admin, .permit, .finalReview, .medium,
                 daysAgo: 60, expected: 10, transitionDaysAgo: [60, 40, 12],
                 notes: "Inspector visited last week. Waiting for final sign-off."),

            // Events
            make("WWDC 2026 Swift Student Challenge", .event, .eventWaitlist, .pending, .high,
                 daysAgo: 4, expected: 25, transitionDaysAgo: [4]),

            make("GDG Devfest Jakarta", .event, .eventRegistration, .pending, .low,
                 daysAgo: 1, expected: 14, transitionDaysAgo: [1]),
        ]
    }

    // MARK: - Archived Items (visible in Archive)

    @MainActor
    private static var archivedItems: [WaitItem] {
        [
            make("Stripe — Mobile Developer", .job, .jobApplication, .positive, .high,
                 daysAgo: 35, transitionDaysAgo: [35, 25, 14, 5], archived: true,
                 notes: "Accepted! Start date in 2 months."),

            make("Shopee — Backend Intern", .job, .jobApplication, .negative, .medium,
                 daysAgo: 20, transitionDaysAgo: [20, 14, 8, 3], archived: true),

            make("AirPods Pro 4", .product, .preOrder, .positive, .medium,
                 daysAgo: 15, transitionDaysAgo: [15, 10, 5, 2], archived: true),

            make("SIM Card Renewal", .admin, .document, .positive, .low,
                 daysAgo: 40, transitionDaysAgo: [40, 25, 7], archived: true),

            make("Local Meetup Speaker Slot", .event, .eventRegistration, .positive, .medium,
                 daysAgo: 10, transitionDaysAgo: [10, 4], archived: true),

            make("Dicoding Scholarship", .job, .scholarship, .negative, .high,
                 daysAgo: 50, transitionDaysAgo: [50, 30, 8], archived: true,
                 notes: "Not selected this round. Will reapply."),
        ]
    }

    // MARK: - Factory

    @MainActor
    private static func make(
        _ title: String,
        _ category: WaitCategory,
        _ template: PipelineTemplate,
        _ targetStatus: WaitStatus,
        _ priority: WaitPriority,
        daysAgo: Int,
        expected: Int? = nil,
        transitionDaysAgo: [Int],
        archived: Bool = false,
        notes: String = ""
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
            notes: notes,
            expectedAt: expectedDate
        )

        // Build realistic statusHistory with proper dates
        // transitionDaysAgo: [28, 18, 8] means submitted 28 days ago, stage2 at 18 days ago, stage3 at 8 days ago
        let stages = template.stages
        var history: [StatusEntry] = []

        // Determine which stages this item went through
        var stagesReached: [WaitStatus] = []
        if let targetIndex = stages.firstIndex(of: targetStatus) {
            stagesReached = Array(stages[0...targetIndex])
        } else if targetStatus.isTerminal {
            stagesReached = stages + [targetStatus]
        } else {
            stagesReached = [stages[0]]
        }

        // Map transitionDaysAgo to stagesReached
        for (index, stage) in stagesReached.enumerated() {
            let daysBack = index < transitionDaysAgo.count ? transitionDaysAgo[index] : 0
            let date = Calendar.current.date(byAdding: .day, value: -daysBack, to: .now) ?? .now
            history.append(StatusEntry(status: stage, timestamp: date))
        }

        // Set final state
        item.status = targetStatus
        item.statusHistory = history
        item.updatedAt = history.last?.timestamp ?? .now

        if archived {
            item.isArchived = true
        }

        return item
    }
}
#endif
