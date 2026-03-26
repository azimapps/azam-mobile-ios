//
//  Theme.swift
//  Awaitr
//

import SwiftUI
import UIKit

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b)
    }

    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - Design Tokens

enum Theme {

    // MARK: Category Colors

    enum CategoryColors {
        static let job     = Color(light: Color(hex: "6C63FF"), dark: Color(hex: "8B83FF"))
        static let product = Color(light: Color(hex: "E24B4A"), dark: Color(hex: "F06B6A"))
        static let admin   = Color(light: Color(hex: "BA7517"), dark: Color(hex: "D4922E"))
        static let event   = Color(light: Color(hex: "3B6D11"), dark: Color(hex: "5A9E2E"))
    }

    // MARK: Priority Colors

    enum PriorityColors {
        static let high   = Color(light: Color(hex: "E24B4A"), dark: Color(hex: "F06B6A"))
        static let medium = Color(light: Color(hex: "EF9F27"), dark: Color(hex: "F5B342"))
        static let low    = Color(light: Color(hex: "97C459"), dark: Color(hex: "ADDA6E"))
    }

    // MARK: Text Colors

    enum TextColors {
        static let primary   = Color(light: Color(hex: "1A1A2E"), dark: Color(hex: "E8E8F0"))
        static let secondary = Color(light: Color(hex: "666680"), dark: Color(hex: "9595B0"))
        static let tertiary  = Color(light: Color(hex: "999999"), dark: Color(hex: "5C5C78"))
    }

    // MARK: Background Colors

    enum BackgroundColors {
        static let base     = Color(light: Color(hex: "F7F6FF"), dark: Color(hex: "0F0F1A"))
        static let card     = Color(light: .white, dark: Color(hex: "1A1A2E"))
        static let elevated = Color(light: .white, dark: Color(hex: "242440"))
    }

    // MARK: Glass Colors

    enum GlassColors {
        static let fill       = Color(light: .white.opacity(0.5), dark: .white.opacity(0.06))
        static let border     = Color(light: .white.opacity(0.3), dark: .white.opacity(0.10))
        static let inactiveBar = Color(light: .black.opacity(0.06), dark: .white.opacity(0.08))
        static let trackBg    = Color(light: Color(hex: "F0F0F4"), dark: Color(hex: "242440"))
    }

    // MARK: Typography

    enum Typography {
        static let pageTitle      = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title          = Font.system(.title2, design: .rounded).weight(.bold)
        static let sectionHeader  = Font.system(.title2, design: .rounded).weight(.semibold)
        static let cardTitle      = Font.system(.body, design: .rounded).weight(.medium)
        static let body           = Font.system(.body)
        static let bodyMedium     = Font.system(.subheadline, design: .rounded).weight(.medium)
        static let buttonLabel    = Font.system(.subheadline, design: .rounded).weight(.semibold)
        static let caption        = Font.system(.footnote).weight(.medium)
        static let captionBold    = Font.system(.footnote, design: .rounded).weight(.semibold)
        static let smallLabel     = Font.system(.caption).weight(.medium)
        static let sectionLabel   = Font.system(.caption2, design: .rounded).weight(.semibold)
        static let smallBadge     = Font.system(.caption2, design: .rounded).weight(.bold)
        static let numericCounter = Font.system(.title, design: .rounded).weight(.bold)
        static let largeIcon      = Font.system(.largeTitle)
        static let statNumber     = Font.system(.caption2, design: .rounded).weight(.bold)
        static let searchField    = Font.system(.subheadline)
    }

    // MARK: Animations

    enum Animations {
        static let springFast   = Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let springMedium = Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let springGentle = Animation.spring(response: 0.5, dampingFraction: 0.85)
        static let fabBounce    = Animation.spring(response: 0.4, dampingFraction: 0.6)
    }

    // MARK: Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: Radii

    enum Radii {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
}
