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

    /// Creates a Route from extracted URL parameters
    /// - Parameter parameters: Dictionary of parameter names to values extracted from URL
    /// - Returns: The constructed Route, or nil if parameters are invalid
    static func createRoute(from parameters: [String: String]) -> Route?

    /// Extracts parameters from a Route for URL construction
    /// - Parameter route: The route to extract parameters from
    /// - Returns: Dictionary of parameter names to values, or empty if no parameters
    static func extractParameters(from route: Route) -> [String: String]

    /// Creates the view for the given route
    /// - Parameters:
    ///   - route: The route to build (may contain associated values)
    ///   - coordinator: The coordinator for navigation
    /// - Returns: The constructed view wrapped in AnyView
    static func createView(from route: Route, coordinator: Coordinator) -> AnyView
}
