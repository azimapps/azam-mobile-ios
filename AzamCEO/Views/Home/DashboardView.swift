//
//  DashboardView.swift
//  AzamCEO
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(filter: WaitItem.activePredicate) private var activeItems: [WaitItem]
    @State private var viewModel: DashboardViewModel?
    @Environment(\.modelContext) private var modelContext
    @State private var showSearch = false
    @State private var showFilters = false

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

    private var selectedStatusesBinding: Binding<Set<WaitStatus>> {
        Binding(
            get: { viewModel?.selectedStatuses ?? [] },
            set: { viewModel?.selectedStatuses = $0 }
        )
    }

    private var selectedPrioritiesBinding: Binding<Set<WaitPriority>> {
        Binding(
            get: { viewModel?.selectedPriorities ?? [] },
            set: { viewModel?.selectedPriorities = $0 }
        )
    }

    private var displayedItems: [WaitItem] {
        viewModel?.filteredItems(from: activeItems) ?? activeItems
    }

    private var activeItemCount: Int {
        activeItems.count
    }

    // MARK: - Greeting

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return String(localized: "Good morning")
        case 12..<17: return String(localized: "Good afternoon")
        case 17..<21: return String(localized: "Good evening")
        default: return String(localized: "Good night")
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack(path: path) {
            ScrollView {
                LazyVStack(spacing: Theme.Spacing.lg) {
                    headerSection
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
            .background {
                LinearGradient(
                    colors: [
                        Theme.BackgroundColors.base,
                        Theme.BackgroundColors.base,
                        Theme.BackgroundColors.base
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: AppDestination.self) { destination in
                switch destination {
                case .itemDetail(let item):
                    ItemDetailView(item: item)
                case .editItem(let item):
                    AddEditItemView(item: item)
                }
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: showSearch)
        .task {
            if viewModel == nil {
                viewModel = DashboardViewModel(modelContext: modelContext)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(greeting)
                        .font(Theme.Typography.bodyMedium)
                        .foregroundStyle(Theme.TextColors.secondary)
                    Text("My Waitlist")
                        .font(Theme.Typography.title)
                        .foregroundStyle(Theme.TextColors.primary)
                }
                .accessibilityElement(children: .combine)
                Spacer()
                filterButton
                searchButton
            }

            if showSearch {
                searchField
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }

            if showFilters {
                FilterPanelView(
                    selectedStatuses: selectedStatusesBinding,
                    selectedPriorities: selectedPrioritiesBinding,
                    onClear: { viewModel?.clearAllFilters() }
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal)
        .animation(Theme.Animations.springFast, value: showSearch)
        .animation(Theme.Animations.springFast, value: showFilters)
    }

    private var filterButton: some View {
        Button {
            showFilters.toggle()
            if !showFilters {
                viewModel?.clearAllFilters()
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .font(Theme.Typography.cardTitle)
                    .foregroundStyle(showFilters ? Theme.CategoryColors.job : Theme.TextColors.secondary)
                    .frame(width: 40, height: 40)
                    .background(Theme.GlassColors.inactiveBar)
                    .clipShape(Circle())

                if let count = viewModel?.activeFilterCount, count > 0 {
                    Text("\(count)")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                        .background(Theme.CategoryColors.product)
                        .clipShape(Circle())
                        .offset(x: 2, y: -2)
                }
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: showFilters)
        .accessibilityLabel(showFilters ? "Close filters" : "Filter items")
        .accessibilityValue(viewModel?.hasActiveFilters == true ? "\(viewModel?.activeFilterCount ?? 0) active filters" : "No filters")
    }

    private var searchButton: some View {
        Button {
            showSearch.toggle()
            if !showSearch {
                viewModel?.searchText = ""
            }
        } label: {
            Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                .font(Theme.Typography.cardTitle)
                .foregroundStyle(Theme.TextColors.secondary)
                .frame(width: 40, height: 40)
                .background(Theme.GlassColors.inactiveBar)
                .clipShape(Circle())
        }
        .accessibilityLabel(showSearch ? "Close search" : "Search items")
        .accessibilityHint("Double tap to toggle search")
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(Theme.Typography.bodyMedium)
                .foregroundStyle(Theme.TextColors.secondary)
            TextField("Search items...", text: searchTextBinding)
                .font(Theme.Typography.searchField)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Search items")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Theme.GlassColors.inactiveBar)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 8)
    }

    // MARK: - Sections

    private var statsSection: some View {
        SummaryStatsView(
            items: activeItems,
            selectedCategory: selectedCategoryBinding
        )
    }

    private var filterSection: some View {
        CategoryFilterBar(
            selectedCategory: selectedCategoryBinding,
            totalCount: activeItemCount
        )
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
