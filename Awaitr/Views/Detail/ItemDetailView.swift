//
//  ItemDetailView.swift
//  Awaitr
//

import SwiftUI
import SwiftData

struct ItemDetailView: View {
    let item: WaitItem
    @State private var viewModel: ItemDetailViewModel?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                metaBar
                pipelineCard
                detailsCard
                timelineCard
                notesCard
                if !item.isArchived {
                    actionButtons
                }
            }
            .padding(Theme.Spacing.lg)
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                viewModel = ItemDetailViewModel(item: item, modelContext: modelContext)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddEditItemView(item: item)
        }
        .confirmationDialog("Delete Item?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel?.deleteItem()
                dismiss()
            }
        } message: {
            Text("This will permanently delete this item.")
        }
    }

    // MARK: - Meta Bar

    private var metaBar: some View {
        HStack {
            CategoryBadge(category: item.category)
            Text(item.category.shortLabel)
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.TextColors.muted)
            Spacer()
            PriorityDot(priority: item.priority)
            Text("\(item.priority.rawValue.capitalized) priority")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(item.priority.color)
        }
    }

    // MARK: - Pipeline Card

    private var pipelineCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                sectionLabel("STATUS PIPELINE")
                PipelineProgressView(status: item.status)
            }
        }
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                sectionLabel("DETAILS")
                detailsGrid
            }
        }
    }

    private var detailsGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: Theme.Spacing.lg),
            GridItem(.flexible(), spacing: Theme.Spacing.lg)
        ]

        return LazyVGrid(columns: columns, alignment: .leading, spacing: Theme.Spacing.md) {
            detailCell(label: "Submitted", value: item.submittedAt.shortFormatted, color: Theme.TextColors.dark)
            detailCell(label: "Days waiting", value: item.daysWaitingLabel, color: item.category.color)
            detailCell(label: "Expected by", value: item.expectedAt?.shortFormatted ?? "Not set", color: Theme.TextColors.dark)
            detailCell(label: "Follow-up", value: item.followUpAt?.shortFormatted ?? "Not set", color: Theme.CategoryColors.admin)
        }
    }

    private func detailCell(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.TextColors.muted)
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(color)
        }
    }

    // MARK: - Timeline Card

    @ViewBuilder
    private var timelineCard: some View {
        if !item.statusHistory.isEmpty {
            GlassCard {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    sectionLabel("TIMELINE")
                    TimelineView(entries: item.statusHistory, categoryColor: item.category.color)
                }
            }
        }
    }

    // MARK: - Notes Card

    @ViewBuilder
    private var notesCard: some View {
        if !item.notes.isEmpty {
            GlassCard {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    sectionLabel("NOTES")
                    Text(item.notes)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "3D3D5C"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 10) {
            if !item.status.isTerminal {
                if let next = item.status.nextStatus {
                    // Non-terminal with next (submitted, inReview)
                    primaryButton("Advance to \(next.shortLabel)") {
                        withAnimation(Theme.Animations.springMedium) {
                            viewModel?.advanceStatus()
                        }
                    }
                    editButton
                    deleteIconButton
                } else {
                    // Awaiting (no nextStatus, not terminal)
                    acceptButton
                    rejectButton
                    editButton
                    deleteIconButton
                }
            } else {
                // Terminal (accepted/rejected)
                editButton
                deleteIconButton
            }
        }
    }

    private func primaryButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.CategoryColors.job)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var acceptButton: some View {
        Button {
            withAnimation(Theme.Animations.springMedium) {
                viewModel?.acceptItem()
            }
        } label: {
            Text("Accept")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "3B6D11"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var rejectButton: some View {
        Button {
            withAnimation(Theme.Animations.springMedium) {
                viewModel?.rejectItem()
            }
        } label: {
            Text("Reject")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "E24B4A"))
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(hex: "E24B4A").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var editButton: some View {
        Button { showEditSheet = true } label: {
            Text("Edit")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.CategoryColors.job)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Theme.CategoryColors.job.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var deleteIconButton: some View {
        Button { showDeleteConfirmation = true } label: {
            Image(systemName: "trash.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "E24B4A"))
                .frame(width: 44, height: 44)
                .background(Color(hex: "E24B4A").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Section Label

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Theme.TextColors.muted)
            .tracking(0.8)
    }
}
