//
//  CategoryBadge.swift
//  Awaitr
//

import SwiftUI

struct CategoryBadge: View {
    let category: WaitCategory

    var body: some View {
        Text(category.shortLabel.uppercased())
            .font(.system(size: 10, weight: .bold))
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
