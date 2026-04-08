//
//  NavigationCoordinator.swift
//  AzamCEO
//

import SwiftUI

@MainActor @Observable
final class NavigationCoordinator {
    var pendingItemId: UUID?
    var pendingAddCategory: WaitCategory?
}
