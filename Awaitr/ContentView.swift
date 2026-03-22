//
//  ContentView.swift
//  Awaitr
//
//  Created by ZoldyckD on 20/03/26.
//

import SwiftUI
import SwiftData

// MARK: - Tab Definition

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case archive
    case settings

    var id: String { rawValue }

    var label: LocalizedStringKey {
        switch self {
        case .home: "Home"
        case .archive: "Archive"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house.fill"
        case .archive: "archivebox.fill"
        case .settings: "gearshape.fill"
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var navigationPath = NavigationPath()
    @State private var showAddSheet = false
    @Environment(NavigationCoordinator.self) private var coordinator
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                Tab(value: .home) {
                    DashboardView(path: $navigationPath, onAddTapped: { showAddSheet = true })
                } label: {
                    Label(AppTab.home.label, systemImage: AppTab.home.systemImage)
                }

                Tab(value: .archive) {
                    ArchiveView()
                } label: {
                    Label(AppTab.archive.label, systemImage: AppTab.archive.systemImage)
                }

                Tab(value: .settings) {
                    SettingsView()
                } label: {
                    Label(AppTab.settings.label, systemImage: AppTab.settings.systemImage)
                }
            }
            .tabViewStyle(.automatic)

            if selectedTab == .home {
                FABButton { showAddSheet = true }
                    .ignoresSafeArea(.keyboard)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddEditItemView()
        }
        .preferredColorScheme(.light)
        .onChange(of: coordinator.pendingItemId) { _, itemId in
            guard let itemId else { return }
            navigateToItem(id: itemId)
            coordinator.pendingItemId = nil
        }
    }

    // MARK: - Deep Link Navigation

    private func navigateToItem(id: UUID) {
        // Fetch the item from SwiftData
        let descriptor = FetchDescriptor<WaitItem>(predicate: #Predicate { $0.id == id })
        guard let item = try? modelContext.fetch(descriptor).first else { return }

        // Switch to home tab and push detail view
        selectedTab = .home
        navigationPath = NavigationPath()
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))
            navigationPath.append(AppDestination.itemDetail(item))
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WaitItem.self, inMemory: true)
        .environment(NavigationCoordinator())
}
