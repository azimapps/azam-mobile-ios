//
//  ArchiveView.swift
//  Awaitr
//

import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Query(filter: WaitItem.archivedPredicate) private var archivedItems: [WaitItem]
    @State private var viewModel: ArchiveViewModel?
    @Environment(\.modelContext) private var modelContext

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
            monthSections
        }
        .listStyle(.plain)
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
                accepted: viewModel?.totalAccepted(from: archivedItems) ?? 0,
                rejected: viewModel?.totalRejected(from: archivedItems) ?? 0
            )
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: Theme.Spacing.lg, bottom: 18, trailing: Theme.Spacing.lg))
        }
    }

    // MARK: - Month Sections

    @ViewBuilder
    private var monthSections: some View {
        let groups = viewModel?.groupedByMonth(from: archivedItems) ?? []
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
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.TextColors.muted)
                    .tracking(0.5)
            }
        }
    }

    // MARK: - Empty

    private var emptyArchive: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer().frame(height: 80)
            Image(systemName: "archivebox")
                .font(.system(size: 48))
                .foregroundStyle(Theme.TextColors.muted)
            Text("No archived items yet")
                .font(Theme.Typography.sectionHeader)
                .foregroundStyle(Theme.TextColors.dark)
        }
        .frame(maxWidth: .infinity)
    }
}
