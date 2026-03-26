//
//  SettingsRow.swift
//  Awaitr
//

import SwiftUI

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let iconColor: Color
    let label: LocalizedStringKey
    var labelColor: Color = Theme.TextColors.primary
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(Theme.Typography.bodyMedium)
                .foregroundStyle(iconColor)
                .frame(width: 30, height: 30)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radii.sm))

            Text(label)
                .font(Theme.Typography.bodyMedium)
                .foregroundStyle(labelColor)

            Spacer()

            trailing()
        }
        .frame(minHeight: 44)
    }
}
