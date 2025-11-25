//
//  Coordinator.swift
//  Ios-MVVM
//
//  Coordinator protocol for navigation
//  Uses URL-based navigation for unified routing
//

import Foundation

@MainActor
protocol Coordinator: AnyObject {
    // MARK: - Basic Navigation
    func pop()
    func popToRoot()

    // MARK: - URL-Based Navigation
    /// Navigate to a screen using a URL
    /// Supports both custom scheme (myapp://) and universal links (https://myapp.com)
    /// Can include optional ?tab=tabName query parameter to specify which tab to open
    ///
    /// Examples:
    /// - myapp://products
    /// - myapp://products/123?tab=products
    /// - https://myapp.com/orders?tab=home
    /// - https://myapp.com/favorites
    func navigate(to url: URL)

    /// Navigate to a screen using a URL string
    /// Convenience method that converts string to URL
    func navigate(to urlString: String)
}
