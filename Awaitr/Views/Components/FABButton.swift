//
//  FABButton.swift
//  Awaitr
//

import SwiftUI

struct FABButton: View {
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: performAction) {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Theme.CategoryColors.job)
                .clipShape(Circle())
                .shadow(color: Theme.CategoryColors.job.opacity(0.4), radius: 8, y: 4)
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .accessibilityLabel("Add new item")
    }

    private func performAction() {
        withAnimation(Theme.Animations.fabBounce) {
            isPressed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(Theme.Animations.fabBounce) {
                isPressed = false
            }
        }
        action()
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        VStack {
            Spacer()
            HStack {
                Spacer()
                FABButton { }
                    .padding()
            }
        }
    }
}
