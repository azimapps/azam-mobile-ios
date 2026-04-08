//
//  PriorityDot.swift
//  AzamCEO
//

import SwiftUI

struct PriorityDot: View {
    let priority: WaitPriority

    var body: some View {
        Circle()
            .fill(priority.color)
            .frame(width: 8, height: 8)
            .accessibilityLabel(Text("\(priority.localizedName) priority"))
    }
}

#Preview {
    HStack(spacing: 12) {
        ForEach(WaitPriority.allCases) { priority in
            HStack(spacing: 4) {
                PriorityDot(priority: priority)
                Text(priority.localizedName)
                    .font(Theme.Typography.caption)
            }
        }
    }
    .padding()
}
