//
//  ArchiveView.swift
//  AzamCEO
//

import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Query(filter: WaitItem.archivedPredicate) private var archivedItems: [WaitItem]
    @State private var viewModel: ArchiveViewModel?
    @State private var unarchiveTrigger = 0
    @Environment(\.modelContext) private var modelContext

    private var searchTextBinding: Binding<String> {
        Binding(
            get: { viewModel?.searchText ?? "" },
            set: { viewModel?.searchText = $0 }
        )
    }

    private var displayedItems: [WaitItem] {
        viewModel?.filteredItems(from: archivedItems) ?? archivedItems
    }

    var body: some View {
        NavigationStack {
            Group {
                if archivedItems.isEmpty {
                    emptyArchive
                } else {
                    archiveList
                }
            }
            .navigationTitle("Archive")
            .searchable(text: searchTextBinding, prompt: "Search archived items")
        }
        .task {
            if viewModel == nil {
                viewModel = ArchiveViewModel(modelContext: modelContext)
            }
        }
    }

    // MARK: - Archive List

    private var archiveList: some View {
        List {
            statsSection
            chartSections
            monthSections
        }
        .listStyle(.plain)
        .sensoryFeedback(.success, trigger: unarchiveTrigger)
        .navigationDestination(for: UUID.self) { itemId in
            if let item = archivedItems.first(where: { $0.id == itemId }) {
                ItemDetailView(item: item)
            }
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        Section {
            ArchiveStatsView(
                accepted: viewModel?.totalAccepted(from: displayedItems) ?? 0,
                rejected: viewModel?.totalRejected(from: displayedItems) ?? 0
            )
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: Theme.Spacing.lg, bottom: 18, trailing: Theme.Spacing.lg))
        }
    }

    // MARK: - Charts

    @ViewBuilder
    private var chartSections: some View {
        if displayedItems.count >= 2 {
            Section {
                CategoryBreakdownChart(
                    data: viewModel?.categoryBreakdown(from: displayedItems) ?? []
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: Theme.Spacing.lg, bottom: 4, trailing: Theme.Spacing.lg))

                MonthlyTrendsChart(
                    data: viewModel?.monthlyTrends(from: displayedItems) ?? []
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: Theme.Spacing.lg, bottom: 4, trailing: Theme.Spacing.lg))

                AverageWaitTimeChart(
                    data: viewModel?.averageWaitTime(from: displayedItems) ?? []
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: Theme.Spacing.lg, bottom: 18, trailing: Theme.Spacing.lg))
            }
        }
    }

    // MARK: - Month Sections

    @ViewBuilder
    private var monthSections: some View {
        let groups = viewModel?.groupedByMonth(from: displayedItems) ?? []
        ForEach(Array(groups.enumerated()), id: \.element.key) { _, group in
            Section {
                ForEach(group.items) { item in
                    NavigationLink(value: item.id) {
                        ArchiveItemCard(item: item)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 2, leading: Theme.Spacing.lg, bottom: 2, trailing: Theme.Spacing.lg))
                    .swipeActions(edge: .trailing) {
                        Button {
                            unarchiveTrigger += 1
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel?.unarchiveItem(item)
                            }
                        } label: {
                            Label("Unarchive", systemImage: "arrow.uturn.backward")
                        }
                        .tint(Theme.CategoryColors.job)
                    }
                }
            } header: {
                Text(group.key.uppercased())
                    .font(Theme.Typography.captionBold)
                    .foregroundStyle(Theme.TextColors.secondary)
                    .tracking(0.5)
            }
        }
    }

    // MARK: - Empty

    private var emptyArchive: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer().frame(height: 80)
            Image(systemName: "archivebox")
                .font(Theme.Typography.largeIcon)
                .foregroundStyle(Theme.TextColors.secondary)
            Text("No archived items yet")
                .font(Theme.Typography.sectionHeader)
                .foregroundStyle(Theme.TextColors.primary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
