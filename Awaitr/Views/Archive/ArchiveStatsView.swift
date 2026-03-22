//
//  ArchiveStatsView.swift
//  Awaitr
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
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Theme.TextColors.muted)
            .tracking(0.8)
    }

    // MARK: - Donut Chart

    private var donutChart: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color(hex: "F0F0F4"), lineWidth: 8)

            // Accepted arc
            Circle()
                .trim(from: 0, to: acceptedRatio)
                .stroke(Color(hex: "3B6D11"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))

            // Rejected arc
            if rejectedRatio > 0 {
                Circle()
                    .trim(from: acceptedRatio, to: acceptedRatio + rejectedRatio)
                    .stroke(Color(hex: "E24B4A"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }

            // Center percentage
            Text(percentageText)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.TextColors.dark)
        }
        .frame(width: 80, height: 80)
    }

    // MARK: - Legend

    private var legend: some View {
        VStack(alignment: .leading, spacing: 8) {
            legendRow(color: Color(hex: "3B6D11"), label: "\(accepted) Accepted")
            legendRow(color: Color(hex: "E24B4A"), label: "\(rejected) Rejected")
        }
    }

    private func legendRow(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.TextColors.dark)
        }
    }
}
