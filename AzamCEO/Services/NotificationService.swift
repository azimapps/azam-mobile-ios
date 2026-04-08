//
//  NotificationService.swift
//  AzamCEO
//

import UserNotifications
import os

enum NotificationService {
    private static let logger = Logger(subsystem: "com.azam", category: "Notifications")

    // MARK: - Notification ID

    /// Deterministic notification identifier for a WaitItem.
    static func notificationId(for itemId: UUID) -> String {
        "azam-followup-\(itemId.uuidString)"
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
        submittedAt: Date,
        at date: Date
    ) async {
        let id = notificationId(for: itemId)

        // Calculate days waiting at the scheduled notification time
        let daysWaiting = Calendar.current.dateComponents([.day], from: submittedAt, to: date).day ?? 0

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Time to follow up!")
        content.body = String(localized: "Check in on: \(title) — it's been \(daysWaiting) days since submission.")
        content.sound = .default
        content.categoryIdentifier = "FOLLOW_UP"
        content.userInfo = ["itemId": itemId.uuidString]


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

    // MARK: - Snooze

    static func snooze(identifier: String, content: UNNotificationContent) async {
        guard let newContent = content.mutableCopy() as? UNMutableNotificationContent else { return }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: newContent, trigger: trigger)
        do {
            try await UNUserNotificationCenter.current().add(request)
            logger.info("Snoozed notification: \(identifier) for 1 hour")
        } catch {
            logger.error("Failed to snooze notification: \(error)")
        }
    }

    // MARK: - Categories (Actions)

    static func registerCategories() {
        let openAction = UNNotificationAction(
            identifier: "OPEN_ACTION",
            title: String(localized: "Open"),
            options: [.foreground]
        )
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: String(localized: "Snooze 1 Hour"),
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
