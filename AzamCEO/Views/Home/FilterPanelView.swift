//
//  FilterPanelView.swift
//  AzamCEO
//

import SwiftUI

struct FilterPanelView: View {
    @Binding var selectedStatuses: Set<WaitStatus>
    @Binding var selectedPriorities: Set<WaitPriority>
    let onClear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            statusSection
            prioritySection
        }
        .padding(.horizontal)
    }

    // MARK: - Status Section

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("STATUS")
                .font(Theme.Typography.sectionLabel)
                .foregroundStyle(Theme.TextColors.secondary)
                .tracking(0.8)

            HStack(spacing: Theme.Spacing.sm) {
                ForEach(WaitStatus.filterCases, id: \.self) { status in
                    filterChip(
                        label: status.shortLabel,
                        icon: status.filterIcon,
                        isSelected: selectedStatuses.contains(status),
                        color: Theme.CategoryColors.job
                    ) {
                        toggleStatus(status)
                    }
                }
            }
        }
    }

    // MARK: - Priority Section

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("PRIORITY")
                .font(Theme.Typography.sectionLabel)
                .foregroundStyle(Theme.TextColors.secondary)
                .tracking(0.8)

            HStack(spacing: Theme.Spacing.sm) {
                ForEach(WaitPriority.allCases) { priority in
                    filterChip(
                        label: priority.localizedName,
                        icon: priority.systemImage,
                        isSelected: selectedPriorities.contains(priority),
                        color: priority.color
                    ) {
                        togglePriority(priority)
                    }
                }
            }
        }
    }

    // MARK: - Chip

    private func filterChip(
        label: String,
        icon: String,
        isSelected: Bool,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(label)
                .font(Theme.Typography.caption)
        }
        .foregroundStyle(isSelected ? color : Theme.TextColors.secondary)
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background {
            if isSelected {
                Capsule().fill(color.opacity(0.12))
            } else {
                Capsule()
                    .fill(Theme.GlassColors.fill)
                    .overlay(Capsule().stroke(Theme.GlassColors.border, lineWidth: 1))
            }
        }
        .onTapGesture(perform: action)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Actions

    private func toggleStatus(_ status: WaitStatus) {
        withAnimation(Theme.Animations.springFast) {
            if selectedStatuses.contains(status) {
                selectedStatuses.remove(status)
            } else {
                selectedStatuses.insert(status)
            }
        }
    }

    private func togglePriority(_ priority: WaitPriority) {
        withAnimation(Theme.Animations.springFast) {
            if selectedPriorities.contains(priority) {
                selectedPriorities.remove(priority)
            } else {
                selectedPriorities.insert(priority)
            }
        }
    }
}
