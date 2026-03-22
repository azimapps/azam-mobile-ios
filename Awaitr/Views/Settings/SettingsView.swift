//
//  SettingsView.swift
//  Awaitr
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel?
    @State private var showReminderPicker = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    generalCard
                    appCard
                    aboutCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Clear All Data?",
                isPresented: clearConfirmationBinding,
                titleVisibility: .visible
            ) {
                Button("Delete Everything", role: .destructive) {
                    viewModel?.confirmFirstClear()
                }
            } message: {
                Text("This will permanently delete all items and notifications.")
            }
            .alert(
                "Are you absolutely sure?",
                isPresented: finalClearBinding
            ) {
                Button("Delete All Data", role: .destructive) {
                    viewModel?.clearAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone. All waitlist items will be permanently removed.")
            }
            .alert(
                "Notifications Disabled",
                isPresented: permissionDeniedBinding
            ) {
                Button("Open Settings") {
                    viewModel?.openSystemSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Notifications are disabled at the system level. Open Settings to enable them for Awaitr.")
            }
        }
        .task {
            if viewModel == nil {
                viewModel = SettingsViewModel(modelContext: modelContext)
            }
            await viewModel?.checkNotificationStatus()
        }
    }

    // MARK: - Bindings

    private var notificationsBinding: Binding<Bool> {
        Binding(
            get: { viewModel?.notificationsEnabled ?? false },
            set: { newValue in
                if newValue {
                    Task { await viewModel?.requestNotificationPermission() }
                } else {
                    viewModel?.notificationsEnabled = false
                }
            }
        )
    }

    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: { viewModel?.defaultReminderTime ?? .now },
            set: { viewModel?.defaultReminderTime = $0 }
        )
    }

    private var clearConfirmationBinding: Binding<Bool> {
        Binding(
            get: { viewModel?.showClearConfirmation ?? false },
            set: { viewModel?.showClearConfirmation = $0 }
        )
    }

    private var finalClearBinding: Binding<Bool> {
        Binding(
            get: { viewModel?.showFinalClearConfirmation ?? false },
            set: { viewModel?.showFinalClearConfirmation = $0 }
        )
    }

    private var permissionDeniedBinding: Binding<Bool> {
        Binding(
            get: { viewModel?.notificationPermissionDenied ?? false },
            set: { viewModel?.notificationPermissionDenied = $0 }
        )
    }

    // MARK: - General Card

    private var generalCard: some View {
        VStack(spacing: 0) {
            SettingsRow(icon: "bell.fill", iconColor: Theme.CategoryColors.job, label: "Notifications") {
                Toggle("", isOn: notificationsBinding)
                    .tint(Theme.CategoryColors.job)
                    .labelsHidden()
            }

            Divider()

            reminderRow

            Divider()

            SettingsRow(icon: "doc.text.fill", iconColor: Theme.CategoryColors.event, label: "Export CSV") {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.TextColors.muted)
            }
            .contentShape(Rectangle())
            .onTapGesture { exportCSV() }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 16)
        .glassCard()
    }

    private var reminderRow: some View {
        VStack(spacing: 0) {
            SettingsRow(icon: "clock.fill", iconColor: Theme.CategoryColors.admin, label: "Default reminder") {
                Text(formattedReminderTime)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.CategoryColors.job)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(Theme.Animations.springFast) {
                    showReminderPicker.toggle()
                }
            }

            if showReminderPicker {
                DatePicker(
                    "Reminder time",
                    selection: reminderTimeBinding,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var formattedReminderTime: String {
        guard let viewModel else { return "9:00 AM" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: viewModel.defaultReminderTime)
    }

    // MARK: - App Card

    private var appCard: some View {
        VStack(spacing: 0) {
            SettingsRow(
                icon: "trash.fill",
                iconColor: Theme.CategoryColors.product,
                label: "Clear all data",
                labelColor: Theme.CategoryColors.product
            ) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.TextColors.muted)
            }
            .contentShape(Rectangle())
            .onTapGesture { viewModel?.requestClearData() }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 16)
        .glassCard()
    }

    // MARK: - About Card

    private var aboutCard: some View {
        VStack(spacing: 0) {
            Text("Awaitr")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.CategoryColors.job)

            Text("Version 1.0.0")
                .font(.system(size: 12))
                .foregroundStyle(Theme.TextColors.muted)
                .padding(.top, 4)

            Text("Made with patience in Ambon")
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: "999999"))
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .glassCard()
    }

    // MARK: - Actions

    private func exportCSV() {
        guard let csv = viewModel?.exportCSV() else { return }
        let activityVC = UIActivityViewController(
            activityItems: [csv],
            applicationActivities: nil
        )
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.keyWindow?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }
}
