#!/usr/bin/env swift

// Run: swift scripts/generate-app-icon.swift
// Outputs PNG files to Awaitr/Assets.xcassets/AppIcon.appiconset/

import SwiftUI
import AppKit

// MARK: - Color Extension (standalone, matches Theme)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Icon View (self-contained)

struct IconView: View {
    let size: CGFloat
    let darkMode: Bool

    var body: some View {
        ZStack {
            background
            letterA
            glassHighlight
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }

    private var background: some View {
        let colors: [Color] = darkMode
            ? [
                Color(hex: "4A44B3"),  // Violet darker
                Color(hex: "9E3534"),  // Coral darker
                Color(hex: "825210"),  // Amber darker
                Color(hex: "294C0C"),  // Green darker
            ]
            : [
                Color(hex: "6C63FF"),  // Violet
                Color(hex: "E24B4A"),  // Coral
                Color(hex: "BA7517"),  // Amber
                Color(hex: "3B6D11"),  // Green
            ]
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var letterA: some View {
        Text("A")
            .font(.system(size: size * 0.55, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(darkMode ? 0.4 : 0.2), radius: size * 0.02, y: size * 0.01)
    }

    private var glassHighlight: some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [.white.opacity(darkMode ? 0.2 : 0.35), .white.opacity(0)],
                    startPoint: .top,
                    endPoint: .center
                )
            )
            .frame(width: size * 0.9, height: size * 0.5)
            .offset(y: -size * 0.2)
    }
}

// MARK: - Tinted Icon (single color silhouette)

struct TintedIconView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Color(hex: "6C63FF")
            Text("A")
                .font(.system(size: size * 0.55, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }
}

// MARK: - Render to PNG

@MainActor
func renderToPNG<V: View>(_ view: V, size: CGFloat, filename: String) {
    let renderer = ImageRenderer(content: view)
    renderer.scale = 1.0  // 1024x1024 at 1x = 1024px
    renderer.proposedSize = .init(width: size, height: size)

    guard let nsImage = renderer.nsImage else {
        print("Failed to render \(filename)")
        return
    }

    guard let tiffData = nsImage.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to convert \(filename) to PNG")
        return
    }

    let scriptDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let projectDir = scriptDir.deletingLastPathComponent()
    let outputDir = projectDir
        .appendingPathComponent("Awaitr/Assets.xcassets/AppIcon.appiconset")

    let outputPath = outputDir.appendingPathComponent(filename)

    do {
        try pngData.write(to: outputPath)
        print("Saved: \(outputPath.path)")
    } catch {
        print("Error writing \(filename): \(error)")
    }
}

// MARK: - Main

@MainActor
func main() {
    let size: CGFloat = 1024

    print("Generating app icons (1024x1024)...")

    renderToPNG(IconView(size: size, darkMode: false), size: size, filename: "AppIcon-Light.png")
    renderToPNG(IconView(size: size, darkMode: true), size: size, filename: "AppIcon-Dark.png")
    renderToPNG(TintedIconView(size: size), size: size, filename: "AppIcon-Tinted.png")

    print("Done! Now update Contents.json to reference these files.")
}

MainActor.assumeIsolated {
    main()
}
