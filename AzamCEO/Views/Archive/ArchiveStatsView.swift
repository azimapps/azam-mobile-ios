//
//  ArchiveStatsView.swift
//  AzamCEO
//

import SwiftUI

struct ArchiveStatsView: View {
    let accepted: Int
    let rejected: Int

    private var total: Int { accepted + rejected }
    private var acceptedRatio: Double { total > 0 ? Double(accepted) / Double(total) : 0 }
    private var rejectedRatio: Double { total > 0 ? Double(rejected) / Double(total) : 0 }

    private var percentageText: String {
        guard total > 0 else { return "—" }
        return "\(Int(acceptedRatio * 100))%"
    }

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                sectionLabel
                HStack(spacing: 16) {
                    donutChart
                    legend
                }
            }
        }
    }

    // MARK: - Section Label

    private var sectionLabel: some View {
        Text("OUTCOMES")
            .font(Theme.Typography.sectionLabel)
            .foregroundStyle(Theme.TextColors.secondary)
            .tracking(0.8)
    }

    // MARK: - Donut Chart

    private var donutChart: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Theme.GlassColors.trackBg, lineWidth: 8)

            // Accepted arc
            Circle()
                .trim(from: 0, to: acceptedRatio)
                .stroke(Theme.CategoryColors.event, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))

            // Rejected arc
            if rejectedRatio > 0 {
                Circle()
                    .trim(from: acceptedRatio, to: acceptedRatio + rejectedRatio)
                    .stroke(Theme.PriorityColors.high, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }

            // Center percentage
            Text(percentageText)
                .font(Theme.Typography.numericCounter)
                .foregroundStyle(Theme.TextColors.primary)
        }
        .frame(width: 80, height: 80)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(percentageText) acceptance rate, \(accepted) successful, \(rejected) unsuccessful")
    }

    // MARK: - Legend

    private var legend: some View {
        VStack(alignment: .leading, spacing: 8) {
            legendRow(icon: "checkmark.circle.fill", color: Theme.CategoryColors.event, label: "\(accepted) Successful")
            legendRow(icon: "xmark.circle.fill", color: Theme.PriorityColors.high, label: "\(rejected) Unsuccessful")
        }
    }

    private func legendRow(icon: String, color: Color, label: LocalizedStringKey) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(Theme.Typography.captionBold)
                .foregroundStyle(Theme.TextColors.primary)
        }
    }
}
