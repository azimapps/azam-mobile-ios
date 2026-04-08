//
//  ItemDetailView.swift
//  AzamCEO
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
    @State private var statusChangeTrigger = 0

    private var template: PipelineTemplate { item.template }

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
        .sensoryFeedback(.warning, trigger: showDeleteConfirmation)
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
            Spacer()
            PriorityDot(priority: item.priority)
            Text("\(item.priority.localizedName) priority")
                .font(Theme.Typography.caption)
                .foregroundStyle(item.priority.color)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Pipeline Card

    private var pipelineCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                sectionLabel("STATUS PIPELINE")
                PipelineProgressView(status: item.status, template: template)
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
            detailCell(label: "Submitted", value: item.submittedAt.shortFormatted, color: Theme.TextColors.primary)
            detailCell(label: "Days waiting", value: item.daysWaitingLabel, color: item.category.color)
            detailCell(label: "Expected by", value: item.expectedAt?.shortFormatted ?? String(localized: "Not set"), color: Theme.TextColors.primary)
            detailCell(label: "Follow-up", value: item.followUpAt?.shortFormatted ?? String(localized: "Not set"), color: Theme.CategoryColors.admin)
        }
    }

    private func detailCell(label: LocalizedStringKey, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(Theme.Typography.sectionLabel)
                .foregroundStyle(Theme.TextColors.secondary)
            Text(value)
                .font(Theme.Typography.bodyMedium)
                .foregroundStyle(color)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Timeline Card

    @ViewBuilder
    private var timelineCard: some View {
        if !item.statusHistory.isEmpty {
            GlassCard {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    sectionLabel("TIMELINE")
                    StatusTimelineView(entries: item.statusHistory, template: template, categoryColor: item.category.color)
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
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.TextColors.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 10) {
            if !item.status.isTerminal {
                if let next = template.nextStatus(after: item.status) {
                    // Non-terminal with next stage
                    primaryButton("Advance to \(template.shortLabel(for: next))") {
                        statusChangeTrigger += 1
                        withAnimation(Theme.Animations.springMedium) {
                            viewModel?.advanceStatus()
                        }
                    }
                    .accessibilityHint("Moves this item to the next pipeline stage")
                    editButton
                    deleteIconButton
                } else {
                    // At last non-terminal stage — show accept/reject
                    acceptButton
                    rejectButton
                    editButton
                    deleteIconButton
                }
            } else {
                // Terminal (positive/negative)
                editButton
                deleteIconButton
            }
        }
        .sensoryFeedback(.success, trigger: statusChangeTrigger)
    }

    private func primaryButton(_ label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(Theme.Typography.buttonLabel)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(item.category.color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var acceptButton: some View {
        Button {
            statusChangeTrigger += 1
            withAnimation(Theme.Animations.springMedium) {
                viewModel?.acceptItem()
            }
        } label: {
            Text(template.shortLabel(for: .positive))
                .font(Theme.Typography.buttonLabel)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.CategoryColors.event)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityHint("Marks this item as successful")
    }

    private var rejectButton: some View {
        Button {
            statusChangeTrigger += 1
            withAnimation(Theme.Animations.springMedium) {
                viewModel?.rejectItem()
            }
        } label: {
            Text(template.shortLabel(for: .negative))
                .font(Theme.Typography.buttonLabel)
                .foregroundStyle(Theme.PriorityColors.high)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Theme.PriorityColors.high.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityHint("Marks this item as unsuccessful")
    }

    private var editButton: some View {
        Button { showEditSheet = true } label: {
            Text("Edit")
                .font(Theme.Typography.buttonLabel)
                .foregroundStyle(item.category.color)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(item.category.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityHint("Edit this item")
    }

    private var deleteIconButton: some View {
        Button { showDeleteConfirmation = true } label: {
            Image(systemName: "trash.fill")
                .font(Theme.Typography.bodyMedium)
                .foregroundStyle(Theme.PriorityColors.high)
                .frame(width: 44, height: 44)
                .background(Theme.PriorityColors.high.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityLabel("Delete item")
        .accessibilityHint("Shows delete confirmation")
    }

    // MARK: - Section Label

    private func sectionLabel(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(Theme.Typography.sectionLabel)
            .foregroundStyle(Theme.TextColors.secondary)
            .tracking(0.8)
    }
}
