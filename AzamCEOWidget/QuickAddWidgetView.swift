//
//  QuickAddWidgetView.swift
//  AzamCEOWidget
//

import SwiftUI
import WidgetKit

struct QuickAddWidgetView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            categoryButtons
        }
        .padding(4)
    }

    private var header: some View {
        HStack(spacing: 6) {
            Image("WidgetLogo")
                .resizable()
                .frame(width: 20, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            Text("Quick Add")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
    }

    private var categoryButtons: some View {
        HStack(spacing: 8) {
            ForEach(WaitCategory.allCases) { category in
                Link(destination: URL(string: "azamceo://add?category=\(category.rawValue)")!) {
                    VStack(spacing: 4) {
                        Text(category.emoji)
                            .font(.title3)
                        Text(category.shortLabel)
                            .font(.system(.caption2, design: .rounded).bold())
                            .foregroundStyle(category.color)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(category.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}
