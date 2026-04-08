//
//  AppIconOption.swift
//  AzamCEO
//

import SwiftUI

struct AppIconOption: Identifiable {
    /// The identifier used with `UIApplication.setAlternateIconName`. `nil` = default icon.
    let id: String?
    let displayName: LocalizedStringKey
    let previewColors: [Color]

    static let allOptions: [AppIconOption] = [
        AppIconOption(
            id: nil,
            displayName: "Default",
            previewColors: [Theme.CategoryColors.job, Color(hex: "8B80FF")]
        ),
        AppIconOption(
            id: "AppIcon-Midnight",
            displayName: "Midnight",
            previewColors: [Color(hex: "1A1A2E"), Color(hex: "3D3D6B")]
        ),
        AppIconOption(
            id: "AppIcon-Ocean",
            displayName: "Ocean",
            previewColors: [Color(hex: "0077B6"), Color(hex: "00B4D8")]
        ),
        AppIconOption(
            id: "AppIcon-Sunset",
            displayName: "Sunset",
            previewColors: [Color(hex: "E24B4A"), Color(hex: "EF9F27")]
        ),
    ]
}
