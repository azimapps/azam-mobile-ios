//
//  FABButton.swift
//  Awaitr
//

import SwiftUI

struct FABButton: View {
    let action: () -> Void

    @State private var isPressed = false
    @State private var isDragging = false
    @State private var position: CGPoint = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var hasInitialized = false

    @AppStorage("fabPositionX") private var savedX: Double = -1
    @AppStorage("fabPositionY") private var savedY: Double = -1

    private let btnSize: CGFloat = 56
    private let edgePadding: CGFloat = 20
    private let bottomPadding: CGFloat = 90

    var body: some View {
        GeometryReader { geo in
            fabContent
                .position(
                    x: position.x + dragOffset.width,
                    y: position.y + dragOffset.height
                )
                .gesture(
                    DragGesture(minimumDistance: 4)
                        .onChanged { value in
                            if !isDragging {
                                isDragging = true
                            }
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            let raw = CGPoint(
                                x: position.x + value.translation.width,
                                y: position.y + value.translation.height
                            )
                            let snapped = snapToEdge(raw, in: geo.size)
                            withAnimation(Theme.Animations.springMedium) {
                                position = snapped
                                dragOffset = .zero
                                isDragging = false
                            }
                            savedX = snapped.x
                            savedY = snapped.y
                        }
                )
                .onTapGesture {
                    guard !isDragging else { return }
                    performAction()
                }
                .onAppear {
                    guard !hasInitialized else { return }
                    hasInitialized = true
                    if savedX >= 0 && savedY >= 0 {
                        position = CGPoint(x: savedX, y: savedY)
                    } else {
                        position = defaultPosition(in: geo.size)
                    }
                }
                .onChange(of: geo.size) { _, newSize in
                    position = clampToSafeArea(position, in: newSize)
                }
        }
        .accessibilityLabel("Add new item")
    }

    // MARK: - Content

    private var fabContent: some View {
        Image(systemName: "plus")
            .font(.title2.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: btnSize, height: btnSize)
            .background(Theme.CategoryColors.job)
            .clipShape(Circle())
            .shadow(
                color: Theme.CategoryColors.job.opacity(isDragging ? 0.6 : 0.4),
                radius: isDragging ? 12 : 8,
                y: isDragging ? 2 : 4
            )
            .scaleEffect(isPressed ? 0.9 : (isDragging ? 1.08 : 1.0))
            .animation(Theme.Animations.springFast, value: isDragging)
            .animation(Theme.Animations.springFast, value: isPressed)
    }

    // MARK: - Positioning

    private func defaultPosition(in containerSize: CGSize) -> CGPoint {
        CGPoint(
            x: containerSize.width - btnSize / 2 - edgePadding,
            y: containerSize.height - btnSize / 2 - bottomPadding
        )
    }

    private func snapToEdge(_ point: CGPoint, in containerSize: CGSize) -> CGPoint {
        let half = btnSize / 2
        let midX = containerSize.width / 2
        let snappedX: CGFloat = point.x < midX
            ? half + edgePadding
            : containerSize.width - half - edgePadding
        let clampedY = min(max(point.y, half + edgePadding), containerSize.height - half - bottomPadding)
        return CGPoint(x: snappedX, y: clampedY)
    }

    private func clampToSafeArea(_ point: CGPoint, in containerSize: CGSize) -> CGPoint {
        let half = btnSize / 2
        let x = min(max(point.x, half + 4), containerSize.width - half - 4)
        let y = min(max(point.y, half + 4), containerSize.height - half - 4)
        return CGPoint(x: x, y: y)
    }

    // MARK: - Tap Animation

    private func performAction() {
        withAnimation(Theme.Animations.fabBounce) {
            isPressed = true
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
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
        FABButton { }
    }
}
