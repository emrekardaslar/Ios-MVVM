//
//  URLRouter.swift
//  Ios-MVVM
//
//  Maps URLs to Routes using ViewModel-defined paths
//  Supports both custom scheme (myapp://) and universal links (https://)
//

import Foundation

@MainActor
class URLRouter {
    // MARK: - URL Patterns

    /// Base URL for universal links (https)
    private let baseURL = "https://myapp.com"

    /// Custom URL scheme
    private let customScheme = "myapp"

    // MARK: - Route to URL Mapping

    /// Converts a Route to a URL using ViewModel paths
    func url(for route: Route) -> URL? {
        // Find the ViewModel that handles this route
        guard let viewModelType = routableTypes.first(where: { $0.canHandle(route: route) }) else {
            return nil
        }

        let config = viewModelType.routeConfig
        var path = config.path

        // Replace path parameters with actual values from the route
        let parameters = viewModelType.extractParameters(from: route)
        for (key, value) in parameters {
            path = path.replacingOccurrences(of: ":\(key)", with: value)
        }

        return URL(string: "\(baseURL)\(path)")
    }

    // MARK: - URL to Route Mapping

    /// Parses a URL and returns the corresponding Route with activity and tab info
    /// Dynamically matches against ViewModel-defined paths
    func route(from url: URL) -> (activity: Activity, tab: Tab, route: Route)? {
        // Handle custom scheme (myapp://products)
        if url.scheme == customScheme {
            return parseCustomSchemeURL(url)
        }

        // Handle universal links (https://myapp.com/products)
        if url.scheme == "https" && url.host == "myapp.com" {
            return parseUniversalLink(url)
        }

        return nil
    }

    // MARK: - Private Parsing Methods

    private func parseCustomSchemeURL(_ url: URL) -> (activity: Activity, tab: Tab, route: Route)? {
        let path = "/" + (url.host ?? "")
        return matchPath(path, parameters: url.queryParameters)
    }

    private func parseUniversalLink(_ url: URL) -> (activity: Activity, tab: Tab, route: Route)? {
        let path = url.path.isEmpty ? "/" : url.path
        return matchPath(path, parameters: url.queryParameters)
    }

    private func matchPath(_ urlPath: String, parameters: [String: String]) -> (activity: Activity, tab: Tab, route: Route)? {
        // Try to match against each ViewModel's path pattern
        for viewModelType in routableTypes {
            let config = viewModelType.routeConfig
            let pathPattern = config.path

            if let route = matchPathPattern(urlPath, against: pathPattern, viewModelType: viewModelType) {
                return (config.activity, config.tab, route)
            }
        }

        return nil
    }

    private func matchPathPattern(_ urlPath: String, against pattern: String, viewModelType: any Routable.Type) -> Route? {
        let urlComponents = urlPath.components(separatedBy: "/").filter { !$0.isEmpty }
        let patternComponents = pattern.components(separatedBy: "/").filter { !$0.isEmpty }

        // Must have same number of components
        guard urlComponents.count == patternComponents.count else {
            return nil
        }

        var extractedParams: [String: String] = [:]

        // Match each component
        for (urlComp, patternComp) in zip(urlComponents, patternComponents) {
            if patternComp.hasPrefix(":") {
                // This is a parameter - extract it
                let paramName = String(patternComp.dropFirst())
                extractedParams[paramName] = urlComp
            } else if urlComp != patternComp {
                // Literal doesn't match
                return nil
            }
        }

        // Pattern matched! Now let the ViewModel create the route from parameters
        return viewModelType.createRoute(from: extractedParams)
    }
}

// MARK: - URL Extension for Query Parameters

extension URL {
    var queryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return [:]
        }

        var parameters: [String: String] = [:]
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
}
