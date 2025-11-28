//
//  Routable.swift
//  Ios-MVVM
//
//  Protocol for self-registering views
//  Each ViewModel conforms to this and declares its route and view builder
//

import SwiftUI

@MainActor
protocol Routable {
    /// Route configuration including activity, tab, path, and auth requirements
    static var routeConfig: RouteConfig { get }

    /// Creates the view for the given route with extracted parameters
    /// - Parameters:
    ///   - parameters: Dictionary of parameter names to values extracted from URL path
    ///   - coordinator: The coordinator for navigation
    /// - Returns: The constructed view wrapped in AnyView
    static func createView(parameters: [String: String], coordinator: Coordinator) -> AnyView
}
