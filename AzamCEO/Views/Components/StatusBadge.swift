//
//  StatusBadge.swift
//  AzamCEO
//

import SwiftUI

struct StatusBadge: View {
    let status: WaitStatus
    let template: PipelineTemplate

    var body: some View {
        Text(template.shortLabel(for: status))
            .font(Theme.Typography.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(Color(status: status))
            .clipShape(Capsule())
            .accessibilityLabel("Status: \(template.label(for: status))")
    }
}

#Preview {
    VStack(spacing: 8) {
        ForEach(PipelineTemplate.allCases) { tmpl in
            HStack(spacing: 8) {
                Text(tmpl.label)
                    .font(.caption)
                    .frame(width: 100, alignment: .trailing)
                ForEach(tmpl.allStagesInOrder, id: \.self) { status in
                    StatusBadge(status: status, template: tmpl)
                }
            }
        }
    }
    .padding()
}
