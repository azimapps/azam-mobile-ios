//
//  DashboardView.swift
//  Awaitr
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(filter: WaitItem.activePredicate) private var activeItems: [WaitItem]
    @State private var viewModel: DashboardViewModel?
    @Environment(\.modelContext) private var modelContext

    let path: Binding<NavigationPath>
    let onAddTapped: () -> Void

    // MARK: - Safe Bindings

    private var selectedCategoryBinding: Binding<WaitCategory?> {
        Binding(
            get: { viewModel?.selectedCategory },
            set: { viewModel?.selectedCategory = $0 }
        )
    }

    private var searchTextBinding: Binding<String> {
        Binding(
            get: { viewModel?.searchText ?? "" },
            set: { viewModel?.searchText = $0 }
        )
    }

    private var displayedItems: [WaitItem] {
        viewModel?.filteredItems(from: activeItems) ?? activeItems
    }

    private var categoryCounts: [WaitCategory: Int] {
        viewModel?.categoryCounts(from: activeItems) ?? [:]
    }

    // MARK: - Body

    var body: some View {
        NavigationStack(path: path) {
            ScrollView {
                LazyVStack(spacing: Theme.Spacing.lg) {
                    if activeItems.isEmpty {
                        emptyContent
                    } else {
                        statsSection
                        filterSection
                        itemListSection
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Awaitr")
            .searchable(text: searchTextBinding, prompt: "Search items")
            .navigationDestination(for: AppDestination.self) { destination in
                switch destination {
                case .itemDetail(let item):
                    ItemDetailView(item: item)
                case .editItem(let item):
                    AddEditItemView(item: item)
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = DashboardViewModel(modelContext: modelContext)
            }
        }
    }

    // MARK: - Sections

    private var statsSection: some View {
        SummaryStatsView(
            counts: categoryCounts,
            selectedCategory: selectedCategoryBinding
        )
    }

    private var filterSection: some View {
        CategoryFilterBar(selectedCategory: selectedCategoryBinding)
    }

    @ViewBuilder
    private var itemListSection: some View {
        if displayedItems.isEmpty {
            EmptyStateView(
                icon: "magnifyingglass",
                heading: "No matches",
                subheading: "Try a different search or filter"
            )
        } else {
            ForEach(displayedItems) { item in
                NavigationLink(value: AppDestination.itemDetail(item)) {
                    WaitItemCard(item: item)
                }
                .buttonStyle(PressableCardStyle())
                .padding(.horizontal)
            }
        }
    }

    private var emptyContent: some View {
        EmptyStateView(
            icon: "tray",
            heading: "Nothing to wait for!",
            subheading: "Tap + to add your first item",
            actionLabel: "Add Item",
            action: onAddTapped
        )
    }
}
