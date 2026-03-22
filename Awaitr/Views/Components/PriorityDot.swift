//
//  PriorityDot.swift
//  Awaitr
//

import SwiftUI

struct PriorityDot: View {
    let priority: WaitPriority

    var body: some View {
        Circle()
            .fill(priority.color)
            .frame(width: 8, height: 8)
            .accessibilityLabel(Text("\(priority.label) priority"))
    }
}

#Preview {
    HStack(spacing: 12) {
        ForEach(WaitPriority.allCases) { priority in
            HStack(spacing: 4) {
                PriorityDot(priority: priority)
                Text(priority.rawValue.capitalized)
                    .font(Theme.Typography.caption)
            }
        }
    }
    .padding()
}
