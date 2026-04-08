//
//  ReviewService.swift
//  AzamCEO
//

import StoreKit
import UIKit
import os

@MainActor
enum ReviewService {
    private static let logger = Logger(subsystem: "com.azam", category: "Review")

    private static let archivedCountKey = "totalArchivedCount"
    private static let lastReviewVersionKey = "lastReviewRequestVersion"
    private static let archiveThreshold = 3

    // MARK: - Public

    /// Call after each archive/accept/reject. Triggers review prompt at threshold, once per version.
    static func recordArchiveAndRequestReviewIfNeeded() {
        let count = incrementArchivedCount()
        logger.debug("Archived item count: \(count)")

        guard count >= archiveThreshold else { return }
        guard !hasRequestedReviewForCurrentVersion else {
            logger.debug("Already requested review for this version")
            return
        }

        logger.info("Requesting App Store review (threshold reached)")
        requestReview()
        markReviewRequested()
    }

    /// User-initiated review request from Settings (no gating).
    static func requestReview() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else {
            logger.warning("No active window scene for review request")
            return
        }
        AppStore.requestReview(in: windowScene)
    }

    // MARK: - Private

    private static func incrementArchivedCount() -> Int {
        let current = UserDefaults.standard.integer(forKey: archivedCountKey)
        let newCount = current + 1
        UserDefaults.standard.set(newCount, forKey: archivedCountKey)
        return newCount
    }

    private static var hasRequestedReviewForCurrentVersion: Bool {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let lastVersion = UserDefaults.standard.string(forKey: lastReviewVersionKey) ?? ""
        return currentVersion == lastVersion
    }

    private static func markReviewRequested() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        UserDefaults.standard.set(currentVersion, forKey: lastReviewVersionKey)
    }
}
