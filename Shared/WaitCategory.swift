//
//  WaitCategory.swift
//  AzamCEO
//

import SwiftUI

enum WaitCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case job
    case product
    case admin
    case event

    var id: String { rawValue }

    // MARK: - Display

    var label: LocalizedStringKey {
        switch self {
        case .job: "Job & Scholarship"
        case .product: "Products & Pre-order"
        case .admin: "Administration"
        case .event: "Events & Community"
        }
    }

    var shortLabel: String {
        switch self {
        case .job: String(localized: "Job")
        case .product: String(localized: "Product")
        case .admin: String(localized: "Admin")
        case .event: String(localized: "Event")
        }
    }

    var emoji: String {
        switch self {
        case .job: "\u{1F4BC}"      // briefcase
        case .product: "\u{1F4E6}"  // package
        case .admin: "\u{1F4CB}"    // clipboard
        case .event: "\u{1F3AA}"    // circus tent
        }
    }

    var systemImage: String {
        switch self {
        case .job: "briefcase.fill"
        case .product: "shippingbox.fill"
        case .admin: "doc.text.fill"
        case .event: "ticket.fill"
        }
    }

    // MARK: - Colors

    var hexColor: String {
        switch self {
        case .job: "6C63FF"
        case .product: "E24B4A"
        case .admin: "BA7517"
        case .event: "3B6D11"
        }
    }

    var color: Color {
        switch self {
        case .job: Theme.CategoryColors.job
        case .product: Theme.CategoryColors.product
        case .admin: Theme.CategoryColors.admin
        case .event: Theme.CategoryColors.event
        }
    }
}
