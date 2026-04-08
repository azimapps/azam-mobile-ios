//
//  AzamCEOApp.swift
//  AzamCEO
//
//  Created by ZoldyckD on 20/03/26.
//

import SwiftUI
import SwiftData
import UserNotifications
import WidgetKit

@main
struct AzamCEOApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var navigationCoordinator = NavigationCoordinator()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WaitItem.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier(SharedConstants.appGroupID)
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    private let notificationDelegate = NotificationDelegate()

    init() {
        NotificationService.registerCategories()
        UNUserNotificationCenter.current().delegate = notificationDelegate

        // Skip onboarding for UI tests
        if CommandLine.arguments.contains("--skip-onboarding") {
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigationCoordinator)
                .fullScreenCover(isPresented: .constant(!hasSeenOnboarding)) {
                    OnboardingView()
                }
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                .task {
                    notificationDelegate.coordinator = navigationCoordinator
                    #if DEBUG
                    seedDemoDataIfNeeded()
                    #endif
                }
        }
        .modelContainer(sharedModelContainer)
    }

    // MARK: - Deep Links

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "azamceo" else { return }

        switch url.host {
        case "item":
            // azamceo://item/{uuid} → navigate to item detail
            if let idString = url.pathComponents.last,
               let itemId = UUID(uuidString: idString) {
                navigationCoordinator.pendingItemId = itemId
            }
        case "add":
            // azamceo://add?category=job → open add sheet with category
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let categoryString = components?.queryItems?.first(where: { $0.name == "category" })?.value
            let category = categoryString.flatMap { WaitCategory(rawValue: $0) }
            navigationCoordinator.pendingAddCategory = category ?? .job
        default:
            break
        }
    }

    // MARK: - Demo Seed

    #if DEBUG
    @MainActor
    private func seedDemoDataIfNeeded() {
        let key = "hasSeededDemoData_v2"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        let context = sharedModelContainer.mainContext

        // Check if DB already has items
        let descriptor = FetchDescriptor<WaitItem>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else {
            UserDefaults.standard.set(true, forKey: key)
            return
        }

        for item in DemoSeedData.allItems {
            context.insert(item)
        }

        UserDefaults.standard.set(true, forKey: key)
    }
    #endif
}

// MARK: - Notification Delegate

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    var coordinator: NavigationCoordinator?

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo

        switch response.actionIdentifier {
        case "SNOOZE_ACTION":
            let identifier = response.notification.request.identifier
            let content = response.notification.request.content
            await NotificationService.snooze(identifier: identifier, content: content)
        default:
            // Default tap or OPEN_ACTION → deep link to item
            if let itemIdString = userInfo["itemId"] as? String,
               let itemId = UUID(uuidString: itemIdString) {
                await MainActor.run {
                    coordinator?.pendingItemId = itemId
                }
            }
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
