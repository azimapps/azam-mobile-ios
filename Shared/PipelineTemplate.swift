//
//  PipelineTemplate.swift
//  AzamCEO
//

import Foundation

enum PipelineTemplate: String, Codable, CaseIterable, Identifiable, Sendable {
    // Job & Scholarship
    case jobApplication
    case scholarship

    // Products & Pre-order
    case preOrder
    case productWaitlist

    // Administration
    case document
    case permit

    // Events & Community
    case eventRegistration
    case eventWaitlist

    var id: String { rawValue }

    // MARK: - Category

    var category: WaitCategory {
        switch self {
        case .jobApplication, .scholarship: .job
        case .preOrder, .productWaitlist: .product
        case .document, .permit: .admin
        case .eventRegistration, .eventWaitlist: .event
        }
    }

    // MARK: - Display

    var label: String {
        switch self {
        case .jobApplication: String(localized: "Job Application")
        case .scholarship: String(localized: "Scholarship")
        case .preOrder: String(localized: "Pre-order")
        case .productWaitlist: String(localized: "Product Waitlist")
        case .document: String(localized: "Document")
        case .permit: String(localized: "Permit / License")
        case .eventRegistration: String(localized: "Registration")
        case .eventWaitlist: String(localized: "Event Waitlist")
        }
    }

    var icon: String {
        switch self {
        case .jobApplication: "briefcase.fill"
        case .scholarship: "graduationcap.fill"
        case .preOrder: "shippingbox.fill"
        case .productWaitlist: "clock.badge.fill"
        case .document: "doc.text.fill"
        case .permit: "person.text.rectangle.fill"
        case .eventRegistration: "ticket.fill"
        case .eventWaitlist: "person.2.fill"
        }
    }

    // MARK: - Pipeline Stages

    /// Non-terminal stages in order for this template.
    var stages: [WaitStatus] {
        switch self {
        case .jobApplication: [.pending, .active, .finalReview]
        case .scholarship: [.pending, .active]
        case .preOrder: [.pending, .active, .finalReview]
        case .productWaitlist: [.pending, .active]
        case .document: [.pending, .active]
        case .permit: [.pending, .active, .finalReview]
        case .eventRegistration: [.pending]
        case .eventWaitlist: [.pending, .active]
        }
    }

    /// All stages including terminals, in pipeline order.
    var allStagesInOrder: [WaitStatus] {
        stages + [.positive, .negative]
    }

    // MARK: - Status Labels

    func label(for status: WaitStatus) -> String {
        switch self {
        case .jobApplication:
            switch status {
            case .pending: String(localized: "Applied")
            case .active: String(localized: "Interviewing")
            case .finalReview: String(localized: "Offer Pending")
            case .positive: String(localized: "Hired")
            case .negative: String(localized: "Rejected")
            }
        case .scholarship:
            switch status {
            case .pending: String(localized: "Applied")
            case .active: String(localized: "Under Review")
            case .finalReview: String(localized: "Under Review")
            case .positive: String(localized: "Awarded")
            case .negative: String(localized: "Not Awarded")
            }
        case .preOrder:
            switch status {
            case .pending: String(localized: "Pre-ordered")
            case .active: String(localized: "Processing")
            case .finalReview: String(localized: "Shipped")
            case .positive: String(localized: "Delivered")
            case .negative: String(localized: "Cancelled")
            }
        case .productWaitlist:
            switch status {
            case .pending: String(localized: "Waitlisted")
            case .active: String(localized: "Available")
            case .finalReview: String(localized: "Available")
            case .positive: String(localized: "Purchased")
            case .negative: String(localized: "Passed")
            }
        case .document:
            switch status {
            case .pending: String(localized: "Filed")
            case .active: String(localized: "Processing")
            case .finalReview: String(localized: "Processing")
            case .positive: String(localized: "Ready")
            case .negative: String(localized: "Denied")
            }
        case .permit:
            switch status {
            case .pending: String(localized: "Applied")
            case .active: String(localized: "Under Review")
            case .finalReview: String(localized: "Inspection")
            case .positive: String(localized: "Approved")
            case .negative: String(localized: "Denied")
            }
        case .eventRegistration:
            switch status {
            case .pending: String(localized: "Registered")
            case .active: String(localized: "Registered")
            case .finalReview: String(localized: "Registered")
            case .positive: String(localized: "Confirmed")
            case .negative: String(localized: "Full")
            }
        case .eventWaitlist:
            switch status {
            case .pending: String(localized: "Waitlisted")
            case .active: String(localized: "Spot Opened")
            case .finalReview: String(localized: "Spot Opened")
            case .positive: String(localized: "Confirmed")
            case .negative: String(localized: "Expired")
            }
        }
    }

    func shortLabel(for status: WaitStatus) -> String {
        switch self {
        case .jobApplication:
            switch status {
            case .pending: String(localized: "Applied")
            case .active: String(localized: "Interview")
            case .finalReview: String(localized: "Offer")
            case .positive: String(localized: "Hired")
            case .negative: String(localized: "Rejected")
            }
        case .scholarship:
            switch status {
            case .pending: String(localized: "Applied")
            case .active: String(localized: "Review")
            case .finalReview: String(localized: "Review")
            case .positive: String(localized: "Awarded")
            case .negative: String(localized: "Not Awarded")
            }
        case .preOrder:
            switch status {
            case .pending: String(localized: "Ordered")
            case .active: String(localized: "Processing")
            case .finalReview: String(localized: "Shipped")
            case .positive: String(localized: "Delivered")
            case .negative: String(localized: "Cancelled")
            }
        case .productWaitlist:
            switch status {
            case .pending: String(localized: "Waitlisted")
            case .active: String(localized: "Available")
            case .finalReview: String(localized: "Available")
            case .positive: String(localized: "Purchased")
            case .negative: String(localized: "Passed")
            }
        case .document:
            switch status {
            case .pending: String(localized: "Filed")
            case .active: String(localized: "Processing")
            case .finalReview: String(localized: "Processing")
            case .positive: String(localized: "Ready")
            case .negative: String(localized: "Denied")
            }
        case .permit:
            switch status {
            case .pending: String(localized: "Applied")
            case .active: String(localized: "Review")
            case .finalReview: String(localized: "Inspection")
            case .positive: String(localized: "Approved")
            case .negative: String(localized: "Denied")
            }
        case .eventRegistration:
            switch status {
            case .pending: String(localized: "Registered")
            case .active: String(localized: "Registered")
            case .finalReview: String(localized: "Registered")
            case .positive: String(localized: "Confirmed")
            case .negative: String(localized: "Full")
            }
        case .eventWaitlist:
            switch status {
            case .pending: String(localized: "Waitlisted")
            case .active: String(localized: "Opened")
            case .finalReview: String(localized: "Opened")
            case .positive: String(localized: "Confirmed")
            case .negative: String(localized: "Expired")
            }
        }
    }

    func systemImage(for status: WaitStatus) -> String {
        switch status {
        case .pending: "paperplane.fill"
        case .active: "eye.fill"
        case .finalReview: "clock.fill"
        case .positive: "checkmark.circle.fill"
        case .negative: "xmark.circle.fill"
        }
    }

    func emoji(for status: WaitStatus) -> String {
        switch status {
        case .pending: "\u{1F4E8}"
        case .active: "\u{1F50D}"
        case .finalReview: "\u{23F3}"
        case .positive: "\u{2705}"
        case .negative: "\u{274C}"
        }
    }

    // MARK: - Transition Logic

    /// Next status in this template's pipeline. Nil at last non-terminal stage.
    func nextStatus(after status: WaitStatus) -> WaitStatus? {
        guard let index = stages.firstIndex(of: status),
              index + 1 < stages.count else {
            return nil
        }
        return stages[index + 1]
    }

    /// Valid transitions from the given status in this template.
    func validTransitions(from status: WaitStatus) -> [WaitStatus] {
        guard !status.isTerminal else { return [] }
        var transitions: [WaitStatus] = []
        if let next = nextStatus(after: status) {
            transitions.append(next)
        }
        transitions.append(contentsOf: [.positive, .negative])
        return transitions
    }

    /// Pipeline index of the given status (0-based). Nil for terminal statuses.
    func pipelineIndex(of status: WaitStatus) -> Int? {
        stages.firstIndex(of: status)
    }

    // MARK: - Factory

    static func templates(for category: WaitCategory) -> [PipelineTemplate] {
        switch category {
        case .job: [.jobApplication, .scholarship]
        case .product: [.preOrder, .productWaitlist]
        case .admin: [.document, .permit]
        case .event: [.eventRegistration, .eventWaitlist]
        }
    }

    static func defaultTemplate(for category: WaitCategory) -> PipelineTemplate {
        templates(for: category).first!
    }
}
