//
//  StatusBadge.swift
//  Awaitr
//

import SwiftUI

struct StatusBadge: View {
    let status: WaitStatus

    var body: some View {
        Text(status.shortLabel)
            .font(Theme.Typography.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(Color(status: status))
            .clipShape(Capsule())
            .accessibilityLabel("Status: \(status.label)")
    }
}

#Preview {
    HStack(spacing: 8) {
        ForEach(WaitStatus.allCases) { status in
            StatusBadge(status: status)
        }
    }
    .padding()
}
