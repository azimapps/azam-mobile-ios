//
//  SettingsViewModel.swift
//  Awaitr
//

import SwiftUI
import SwiftData

@MainActor @Observable
final class SettingsViewModel {
    var notificationsEnabled: Bool = false
    var showClearConfirmation: Bool = false

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Notifications

    func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationsEnabled = settings.authorizationStatus == .authorized
    }

    // MARK: - Export

    func exportCSV() -> String {
        let descriptor = FetchDescriptor<WaitItem>()
        let items = (try? modelContext.fetch(descriptor)) ?? []
        return ExportService.generateCSV(from: items)
    }

    // MARK: - Clear Data

    func clearAllData() {
        let descriptor = FetchDescriptor<WaitItem>()
        guard let items = try? modelContext.fetch(descriptor) else { return }
        for item in items {
            NotificationService.cancel(for: item.id)
            modelContext.delete(item)
        }
        NotificationService.cancelAll()
    }
}
