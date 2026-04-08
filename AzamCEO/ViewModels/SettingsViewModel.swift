//
//  SettingsViewModel.swift
//  AzamCEO
//

import SwiftUI
import SwiftData
import WidgetKit
import os

@MainActor @Observable
final class SettingsViewModel {
    var notificationsEnabled: Bool = false
    var notificationPermissionDenied: Bool = false
    var showClearConfirmation: Bool = false
    var showFinalClearConfirmation: Bool = false

    var defaultReminderHour: Int {
        didSet { UserDefaults.standard.set(defaultReminderHour, forKey: "defaultReminderHour") }
    }
    var defaultReminderMinute: Int {
        didSet { UserDefaults.standard.set(defaultReminderMinute, forKey: "defaultReminderMinute") }
    }

    var defaultReminderTime: Date {
        get {
            Calendar.current.date(from: DateComponents(hour: defaultReminderHour, minute: defaultReminderMinute)) ?? .now
        }
        set {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            defaultReminderHour = comps.hour ?? 9
            defaultReminderMinute = comps.minute ?? 0
        }
    }

    /// Currently selected alternate icon name (`nil` = default).
    var selectedIconName: String? = UIApplication.shared.alternateIconName

    private let modelContext: ModelContext
    private let logger = Logger(subsystem: "com.azam", category: "Settings")

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.defaultReminderHour = UserDefaults.standard.object(forKey: "defaultReminderHour") as? Int ?? 9
        self.defaultReminderMinute = UserDefaults.standard.object(forKey: "defaultReminderMinute") as? Int ?? 0
    }

    // MARK: - App Icon

    func setAlternateIcon(_ name: String?) {
        let previousName = selectedIconName
        selectedIconName = name

        Task {
            do {
                try await UIApplication.shared.setAlternateIconName(name)
                logger.info("App icon changed to: \(name ?? "Default")")
            } catch {
                // Revert UI if the icon change fails (e.g., icon not registered yet)
                selectedIconName = previousName
                logger.warning("Icon not available yet: \(name ?? "Default"). Add icon assets in Xcode.")
            }
        }
    }

    // MARK: - Notifications

    func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationsEnabled = settings.authorizationStatus == .authorized
    }

    func requestNotificationPermission() async {
        let granted = await NotificationService.requestPermission()
        notificationsEnabled = granted
        if !granted {
            notificationPermissionDenied = true
        }
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Export

    func exportCSV() -> String {
        let descriptor = FetchDescriptor<WaitItem>()
        let items = (try? modelContext.fetch(descriptor)) ?? []
        return ExportService.generateCSV(from: items)
    }

    // MARK: - Clear Data

    func requestClearData() {
        showClearConfirmation = true
    }

    func confirmFirstClear() {
        showFinalClearConfirmation = true
    }

    func clearAllData() {
        let descriptor = FetchDescriptor<WaitItem>()
        guard let items = try? modelContext.fetch(descriptor) else { return }
        for item in items {
            NotificationService.cancel(for: item.id)
            modelContext.delete(item)
        }
        NotificationService.cancelAll()
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        logger.info("All data cleared")
    }
}
