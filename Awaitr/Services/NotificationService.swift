//
//  NotificationService.swift
//  Awaitr
//

import UserNotifications
import os

enum NotificationService {
    private static let logger = Logger(subsystem: "com.awaitr", category: "Notifications")

    // MARK: - Notification ID

    /// Deterministic notification identifier for a WaitItem.
    static func notificationId(for itemId: UUID) -> String {
        "awaitr-followup-\(itemId.uuidString)"
    }

    // MARK: - Permission

    static func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            logger.info("Notification permission: \(granted)")
            return granted
        } catch {
            logger.error("Failed to request notification permission: \(error)")
            return false
        }
    }

    // MARK: - Scheduling

    static func scheduleFollowUp(
        for itemId: UUID,
        title: String,
        category: WaitCategory,
        at date: Date
    ) async {
        let id = notificationId(for: itemId)

        let content = UNMutableNotificationContent()
        content.title = "Follow Up"
        content.body = "\(category.emoji) \(title) — time to check in!"
        content.sound = .default
        content.categoryIdentifier = "FOLLOW_UP"

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            logger.info("Scheduled follow-up for \(title) at \(date)")
        } catch {
            logger.error("Failed to schedule notification: \(error)")
        }
    }

    // MARK: - Cancellation

    static func cancel(for itemId: UUID) {
        let id = notificationId(for: itemId)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        logger.info("Cancelled notification: \(id)")
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        logger.info("Cancelled all notifications")
    }

    // MARK: - Status

    static func pendingCount() async -> Int {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.count
    }

    // MARK: - Categories (Actions)

    static func registerCategories() {
        let openAction = UNNotificationAction(
            identifier: "OPEN_ACTION",
            title: "Open",
            options: [.foreground]
        )
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 1 Hour",
            options: []
        )

        let followUpCategory = UNNotificationCategory(
            identifier: "FOLLOW_UP",
            actions: [openAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([followUpCategory])
        logger.info("Registered notification categories")
    }
}
