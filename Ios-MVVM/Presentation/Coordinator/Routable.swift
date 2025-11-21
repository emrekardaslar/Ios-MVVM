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
    /// The route identifier this view handles
    static var routeIdentifier: String { get }

    /// Creates the view for the given route
    /// - Parameters:
    ///   - route: The route to build (may contain associated values)
    ///   - coordinator: The coordinator for navigation
    /// - Returns: The constructed view wrapped in AnyView
    static func createView(from route: Route, coordinator: Coordinator) -> AnyView
}
