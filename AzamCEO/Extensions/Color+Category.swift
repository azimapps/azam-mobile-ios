//
//  Color+Category.swift
//  AzamCEO
//

import SwiftUI

extension Color {
    init(category: WaitCategory) {
        switch category {
        case .job: self = Theme.CategoryColors.job
        case .product: self = Theme.CategoryColors.product
        case .admin: self = Theme.CategoryColors.admin
        case .event: self = Theme.CategoryColors.event
        }
    }

    init(priority: WaitPriority) {
        switch priority {
        case .high: self = Theme.PriorityColors.high
        case .medium: self = Theme.PriorityColors.medium
        case .low: self = Theme.PriorityColors.low
        }
    }

    init(status: WaitStatus) {
        switch status {
        case .pending: self = .gray
        case .active: self = .blue
        case .finalReview: self = .orange
        case .positive: self = Theme.CategoryColors.event
        case .negative: self = Theme.PriorityColors.high
        }
    }
}
