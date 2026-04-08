//
//  CategoryBadge.swift
//  AzamCEO
//

import SwiftUI

struct CategoryBadge: View {
    let category: WaitCategory

    var body: some View {
        Text(category.shortLabel.uppercased())
            .font(Theme.Typography.smallBadge)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(category.color)
            .clipShape(Capsule())
            .accessibilityLabel("\(category.shortLabel) category")
    }
}

#Preview {
    HStack(spacing: 8) {
        ForEach(WaitCategory.allCases) { category in
            CategoryBadge(category: category)
        }
    }
    .padding()
}
