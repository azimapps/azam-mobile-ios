//
//  AppIconView.swift
//  AzamCEO
//

import SwiftUI

struct AppIconView: View {
    var size: CGFloat = 200

    var body: some View {
        ZStack {
            background
            letterA
            glassHighlight
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }

    // MARK: - Background Gradient

    private var background: some View {
        LinearGradient(
            colors: [
                Theme.CategoryColors.job,
                Theme.CategoryColors.product,
                Theme.CategoryColors.admin,
                Theme.CategoryColors.event
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Letter A

    private var letterA: some View {
        Text("A")
            .font(.system(size: size * 0.55, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.2), radius: size * 0.02, y: size * 0.01)
    }

    // MARK: - Glass Highlight

    private var glassHighlight: some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [.white.opacity(0.35), .white.opacity(0)],
                    startPoint: .top,
                    endPoint: .center
                )
            )
            .frame(width: size * 0.9, height: size * 0.5)
            .offset(y: -size * 0.2)
    }
}

#Preview {
    VStack(spacing: 24) {
        AppIconView(size: 256)
        AppIconView(size: 60)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
