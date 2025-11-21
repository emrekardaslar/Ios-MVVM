//
//  RoutableRegistry.swift
//  Ios-MVVM
//
//  Central registry for all routable view models
//  Uses auto-generated routableTypes array from RoutableTypes.swift
//

import Foundation

@MainActor
class RoutableRegistry {
    /// Registers all routable types with the coordinator
    /// - Parameter coordinator: The coordinator to register routes with
    ///
    /// Note: The routableTypes array is auto-generated in RoutableTypes.swift
    /// by the build script. If you get a compile error about routableTypes
    /// not being found, build the project to generate it.
    static func registerAll(with coordinator: AppCoordinator) {
        routableTypes.forEach { routableType in
            coordinator.register(identifier: routableType.routeIdentifier) { route in
                routableType.createView(from: route, coordinator: coordinator)
            }
        }
    }
}
