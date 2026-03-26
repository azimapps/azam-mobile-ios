//
//  WaitPriority.swift
//  Awaitr
//

import SwiftUI

enum WaitPriority: String, Codable, CaseIterable, Identifiable, Sendable {
    case high
    case medium
    case low

    var id: String { rawValue }

    // MARK: - Display

    var label: LocalizedStringKey {
        switch self {
        case .high: "High"
        case .medium: "Medium"
        case .low: "Low"
        }
    }

    var localizedName: String {
        switch self {
        case .high: String(localized: "High")
        case .medium: String(localized: "Medium")
        case .low: String(localized: "Low")
        }
    }

    var systemImage: String {
        switch self {
        case .high: "exclamationmark.circle.fill"
        case .medium: "minus.circle.fill"
        case .low: "arrow.down.circle.fill"
        }
    }

    // MARK: - Sorting

    /// Sort order: high=0 (first), medium=1, low=2 (last).
    var sortOrder: Int {
        switch self {
        case .high: 0
        case .medium: 1
        case .low: 2
        }
    }

    // MARK: - Colors

    var hexColor: String {
        switch self {
        case .high: "E24B4A"
        case .medium: "EF9F27"
        case .low: "97C459"
        }
    }

    var color: Color {
        switch self {
        case .high: Theme.PriorityColors.high
        case .medium: Theme.PriorityColors.medium
        case .low: Theme.PriorityColors.low
        }
    }
}
