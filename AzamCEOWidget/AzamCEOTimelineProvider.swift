//
//  AzamCEOTimelineProvider.swift
//  AzamCEOWidget
//

import WidgetKit
import SwiftData

struct AzamCEOTimelineProvider: TimelineProvider {

    // MARK: - Placeholder

    func placeholder(in context: Context) -> AzamCEOWidgetEntry {
        .placeholder
    }

    // MARK: - Snapshot

    func getSnapshot(in context: Context, completion: @escaping (AzamCEOWidgetEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
            return
        }
        completion(fetchEntry())
    }

    // MARK: - Timeline

    func getTimeline(in context: Context, completion: @escaping (Timeline<AzamCEOWidgetEntry>) -> Void) {
        let entry = fetchEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    // MARK: - Data Fetch

    private func fetchEntry() -> AzamCEOWidgetEntry {
        do {
            let schema = Schema([WaitItem.self])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                groupContainer: .identifier(SharedConstants.appGroupID)
            )
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = ModelContext(container)

            var descriptor = FetchDescriptor<WaitItem>(
                predicate: WaitItem.activePredicate
            )
            descriptor.sortBy = [SortDescriptor(\.expectedAt)]

            let items = (try? context.fetch(descriptor)) ?? []

            // Find nearest deadline
            let itemsWithDeadline = items
                .filter { $0.expectedAt != nil }
                .sorted { ($0.expectedAt ?? .distantFuture) < ($1.expectedAt ?? .distantFuture) }
            let nearest = itemsWithDeadline.first

            // Category breakdown
            var breakdown: [WaitCategory: Int] = [:]
            for item in items {
                breakdown[item.category, default: 0] += 1
            }

            return AzamCEOWidgetEntry(
                date: .now,
                activeCount: items.count,
                nearestDeadlineId: nearest?.id,
                nearestDeadlineTitle: nearest?.title,
                nearestDeadlineDate: nearest?.expectedAt,
                nearestDeadlineCategory: nearest?.category,
                categoryBreakdown: breakdown
            )
        } catch {
            return .empty
        }
    }
}
