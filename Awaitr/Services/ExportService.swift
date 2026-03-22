//
//  ExportService.swift
//  Awaitr
//

import Foundation
import os

enum ExportService {
    private static let logger = Logger(subsystem: "com.awaitr", category: "Export")

    /// Generates a CSV string from an array of WaitItems.
    /// Columns: Title, Category, Status, Priority, Submitted, Expected, Follow-up, Notes, Archived, Days Waiting
    /// Uses RFC 4180 escaping and ISO 8601 dates.
    static func generateCSV(from items: [WaitItem]) -> String {
        let header = "Title,Category,Status,Priority,Submitted,Expected,Follow-up,Notes,Archived,Days Waiting"
        let rows = items.map { item in
            [
                escapeCSV(item.title),
                escapeCSV(item.category.shortLabel),
                escapeCSV(item.status.label),
                escapeCSV(item.priority.rawValue.capitalized),
                formatDate(item.submittedAt),
                item.expectedAt.map(formatDate) ?? "",
                item.followUpAt.map(formatDate) ?? "",
                escapeCSV(item.notes),
                item.isArchived ? "Yes" : "No",
                "\(item.daysWaiting)"
            ].joined(separator: ",")
        }

        let csv = ([header] + rows).joined(separator: "\n")
        logger.info("Generated CSV with \(items.count) items")
        return csv
    }

    // MARK: - Helpers

    private static func escapeCSV(_ value: String) -> String {
        let needsQuoting = value.contains(",") || value.contains("\"") || value.contains("\n")
        if needsQuoting {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }

    private nonisolated static func formatDate(_ date: Date) -> String {
        date.formatted(.iso8601)
    }
}
