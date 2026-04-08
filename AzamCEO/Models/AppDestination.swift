//
//  AppDestination.swift
//  AzamCEO
//

import Foundation

/// Navigation destination for typed NavigationPath.
enum AppDestination: Hashable {
    case itemDetail(WaitItem)
    case editItem(WaitItem)
}
