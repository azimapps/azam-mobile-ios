//
//  WaitStatus.swift
//  AzamCEO
//

import SwiftUI

enum WaitStatus: String, Codable, CaseIterable, Identifiable, Sendable {
    case pending
    case active
    case finalReview
    case positive
    case negative

    var id: String { rawValue }

    // MARK: - Terminal Detection

    var isTerminal: Bool {
        self == .positive || self == .negative
    }

    var isPositive: Bool { self == .positive }
    var isNegative: Bool { self == .negative }

    /// Non-terminal statuses shown in dashboard filters.
    static var filterCases: [WaitStatus] {
        [.pending, .active, .finalReview]
    }

    // MARK: - Display

    var label: LocalizedStringKey {
        switch self {
        case .pending: "Pending"
        case .active: "Active"
        case .finalReview: "Final Review"
        case .positive: "Successful"
        case .negative: "Unsuccessful"
        }
    }

    var shortLabel: String {
        switch self {
        case .pending: String(localized: "Pending")
        case .active: String(localized: "Active")
        case .finalReview: String(localized: "Review")
        case .positive: String(localized: "Success")
        case .negative: String(localized: "Fail")
        }
    }

    var filterIcon: String {
        switch self {
        case .pending: "clock"
        case .active: "bolt.fill"
        case .finalReview: "eye.fill"
        case .positive: "checkmark.circle.fill"
        case .negative: "xmark.circle.fill"
        }
    }

    // MARK: - Migration Decoder

    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        switch rawValue {
        // Legacy raw values
        case "submitted": self = .pending
        case "inReview": self = .active
        case "awaiting": self = .finalReview
        case "accepted": self = .positive
        case "rejected": self = .negative
        default:
            guard let status = WaitStatus(rawValue: rawValue) else {
                throw DecodingError.dataCorruptedError(
                    in: try decoder.singleValueContainer(),
                    debugDescription: "Unknown WaitStatus raw value: \(rawValue)"
                )
            }
            self = status
        }
    }
}
