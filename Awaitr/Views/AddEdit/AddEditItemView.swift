//
//  AddEditItemView.swift
//  Awaitr
//

import SwiftUI
import SwiftData

struct AddEditItemView: View {
    @State private var viewModel: AddEditViewModel?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var expandedDateField: DateField?
    @State private var saveTrigger = 0

    let item: WaitItem?

    private enum DateField: Hashable {
        case submitted, expected, followUp
    }

    init(item: WaitItem? = nil) {
        self.item = item
    }

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    formContent(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(item != nil ? "Edit Item" : "New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.CategoryColors.job)
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTrigger += 1
                        Task {
                            await viewModel?.save()
                            dismiss()
                        }
                    }
                    .foregroundStyle(Theme.CategoryColors.job)
                    .fontWeight(.bold)
                    .disabled(viewModel?.isValid != true)
                    .opacity(viewModel?.isValid == true ? 1 : 0.4)
                }
            }
        }
        .sensoryFeedback(.success, trigger: saveTrigger)
        .task {
            if viewModel == nil {
                if let item {
                    viewModel = AddEditViewModel(item: item, modelContext: modelContext)
                } else {
                    viewModel = AddEditViewModel(modelContext: modelContext)
                }
            }
        }
    }

    // MARK: - Form Content

    @ViewBuilder
    private func formContent(_ vm: AddEditViewModel) -> some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                titleCard(vm)
                categoryCard(vm)
                templateCard(vm)
                datesCard(vm)
                priorityCard(vm)
                notesCard(vm)
            }
            .padding(Theme.Spacing.lg)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Title Card

    private func titleCard(_ vm: AddEditViewModel) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                sectionLabel("TITLE")
                HStack {
                    TextField("What are you waiting for?", text: Binding(
                        get: { vm.title },
                        set: { vm.title = $0 }
                    ))
                    .textInputAutocapitalization(.sentences)
                    .font(Theme.Typography.body)
                    .accessibilityLabel("Item title")

                    Text("\(vm.titleCharacterCount)/80")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(vm.titleCharacterCount > 80 ? .red : Theme.TextColors.secondary)
                        .accessibilityHidden(true)
                }
                Divider()
            }
        }
    }

    // MARK: - Category Card

    private func categoryCard(_ vm: AddEditViewModel) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                sectionLabel("CATEGORY")
                CategoryPickerView(selectedCategory: Binding(
                    get: { vm.category },
                    set: { vm.updateCategory($0) }
                ))
            }
        }
        .sensoryFeedback(.selection, trigger: vm.category)
    }

    // MARK: - Template Card

    private func templateCard(_ vm: AddEditViewModel) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                sectionLabel("TYPE")
                templateSelector(vm)
            }
        }
    }

    private func templateSelector(_ vm: AddEditViewModel) -> some View {
        let templates = PipelineTemplate.templates(for: vm.category)
        return HStack(spacing: 8) {
            ForEach(templates) { tmpl in
                let isSelected = vm.template == tmpl
                Button {
                    withAnimation(Theme.Animations.springFast) {
                        vm.template = tmpl
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tmpl.icon)
                            .font(Theme.Typography.smallLabel)
                        Text(tmpl.label)
                            .font(Theme.Typography.caption)
                    }
                    .foregroundStyle(isSelected ? Color(category: vm.category) : Theme.TextColors.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isSelected ? Color(category: vm.category).opacity(0.08) : .clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                isSelected ? Color(category: vm.category) : Theme.GlassColors.inactiveBar,
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
                .accessibilityHint("Double tap to select this pipeline type")
            }
        }
    }

    // MARK: - Dates Card

    private func datesCard(_ vm: AddEditViewModel) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 0) {
                sectionLabel("DATES")
                    .padding(.bottom, Theme.Spacing.sm)

                dateRow(
                    label: "Submitted",
                    value: vm.submittedAt.shortFormatted,
                    isSet: true,
                    field: .submitted
                )

                if expandedDateField == .submitted {
                    DatePicker("", selection: Binding(
                        get: { vm.submittedAt },
                        set: { vm.submittedAt = $0 }
                    ), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Theme.CategoryColors.job)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Divider().padding(.vertical, 4)

                dateRow(
                    label: "Expected by",
                    value: vm.hasExpectedDate ? (vm.expectedAt ?? .now).shortFormatted : nil,
                    isSet: vm.hasExpectedDate,
                    field: .expected
                )

                if expandedDateField == .expected {
                    expandedDatePicker(
                        date: Binding(
                            get: { vm.expectedAt ?? .now },
                            set: { vm.expectedAt = $0 }
                        ),
                        isEnabled: vm.hasExpectedDate,
                        onClear: {
                            withAnimation(Theme.Animations.springFast) {
                                vm.hasExpectedDate = false
                                vm.expectedAt = nil
                                expandedDateField = nil
                            }
                        }
                    )
                    .onAppear {
                        if !vm.hasExpectedDate {
                            vm.hasExpectedDate = true
                            vm.expectedAt = .now
                        }
                    }
                }

                Divider().padding(.vertical, 4)

                dateRow(
                    label: "Follow-up reminder",
                    value: vm.hasFollowUpDate ? followUpDisplay(vm.followUpAt) : nil,
                    isSet: vm.hasFollowUpDate,
                    field: .followUp
                )

                if expandedDateField == .followUp {
                    followUpDatePicker(vm)
                }
            }
        }
    }

    private func dateRow(label: String, value: String?, isSet: Bool, field: DateField) -> some View {
        Button {
            withAnimation(Theme.Animations.springFast) {
                expandedDateField = expandedDateField == field ? nil : field
            }
        } label: {
            HStack {
                Text(label)
                    .font(Theme.Typography.bodyMedium)
                    .foregroundStyle(Theme.TextColors.primary)
                Spacer()
                Text(value ?? String(localized: "Set date"))
                    .font(Theme.Typography.bodyMedium)
                    .foregroundStyle(isSet ? Theme.CategoryColors.job : Theme.TextColors.tertiary)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Double tap to expand date picker")
    }

    private func followUpDatePicker(_ vm: AddEditViewModel) -> some View {
        VStack {
            DatePicker(
                "",
                selection: Binding(
                    get: { vm.followUpAt ?? defaultFollowUpDate },
                    set: { vm.followUpAt = $0 }
                ),
                in: Date.now...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .tint(Theme.CategoryColors.job)

            if vm.hasFollowUpDate {
                Button("Clear") {
                    withAnimation(Theme.Animations.springFast) {
                        vm.hasFollowUpDate = false
                        vm.followUpAt = nil
                        expandedDateField = nil
                    }
                }
                .font(Theme.Typography.caption)
                .foregroundStyle(.red)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
        .onAppear {
            if !vm.hasFollowUpDate {
                vm.hasFollowUpDate = true
                vm.followUpAt = defaultFollowUpDate
            }
        }
    }

    private func followUpDisplay(_ date: Date?) -> String {
        guard let date else { return String(localized: "Set date") }
        return date.formatted(.dateTime.month(.abbreviated).day().hour().minute())
    }

    private var defaultFollowUpDate: Date {
        let hour = UserDefaults.standard.object(forKey: "defaultReminderHour") as? Int ?? 9
        let minute = UserDefaults.standard.object(forKey: "defaultReminderMinute") as? Int ?? 0
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        return Calendar.current.date(
            bySettingHour: hour, minute: minute, second: 0, of: tomorrow
        ) ?? tomorrow
    }

    private func expandedDatePicker(date: Binding<Date>, isEnabled: Bool, onClear: @escaping () -> Void) -> some View {
        VStack {
            DatePicker("", selection: date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Theme.CategoryColors.job)

            if isEnabled {
                Button("Clear") { onClear() }
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.red)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Priority Card

    private func priorityCard(_ vm: AddEditViewModel) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                sectionLabel("PRIORITY")
                prioritySelector(vm)
            }
        }
        .sensoryFeedback(.selection, trigger: vm.priority)
    }

    private func prioritySelector(_ vm: AddEditViewModel) -> some View {
        HStack(spacing: 8) {
            ForEach(WaitPriority.allCases) { p in
                let isSelected = vm.priority == p
                Button {
                    withAnimation(Theme.Animations.springFast) {
                        vm.priority = p
                    }
                } label: {
                    HStack(spacing: 4) {
                        PriorityDot(priority: p)
                        Text(p.rawValue.capitalized)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(isSelected ? p.color : Theme.TextColors.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isSelected ? p.color.opacity(0.08) : .clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                isSelected ? p.color : Theme.GlassColors.inactiveBar,
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }

    // MARK: - Notes Card

    private func notesCard(_ vm: AddEditViewModel) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack {
                    sectionLabel("NOTES")
                    Spacer()
                    Text("\(vm.notesCharacterCount)/500")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(vm.notesCharacterCount > 500 ? .red : Theme.TextColors.secondary)
                }
                ZStack(alignment: .topLeading) {
                    TextEditor(text: Binding(
                        get: { vm.notes },
                        set: { vm.notes = $0 }
                    ))
                    .scrollContentBackground(.hidden)
                    .font(Theme.Typography.body)
                    .frame(minHeight: 80)

                    if vm.notes.isEmpty {
                        Text("Add notes...")
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.TextColors.tertiary)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
    }

    // MARK: - Section Label

    private func sectionLabel(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(Theme.Typography.sectionLabel)
            .foregroundStyle(Theme.TextColors.secondary)
            .tracking(0.8)
    }
}
