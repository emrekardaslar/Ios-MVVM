//
//  URLRouter.swift
//  Ios-MVVM
//
//  Maps URLs to Routes for unified navigation
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

    /// Converts a Route to a URL
    /// Used for generating URLs from routes
    func url(for route: Route) -> URL? {
        let path: String

        switch route {
        case .home:
            path = "/home"
        case .productList:
            path = "/products"
        case .productDetail(let product):
            path = "/products/\(product.id)"
        case .favorites:
            path = "/favorites"
        case .orders:
            path = "/orders"
        case .reviews:
            path = "/reviews"
        }

        return URL(string: "\(baseURL)\(path)")
    }

    // MARK: - URL to Route Mapping

    /// Parses a URL and returns the corresponding Route
    /// Supports both custom scheme (myapp://) and universal links (https://myapp.com)
    func route(from url: URL) -> Route? {
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

    private func parseCustomSchemeURL(_ url: URL) -> Route? {
        let path = url.host ?? ""
        return parsePathComponents(path, parameters: url.queryParameters)
    }

    private func parseUniversalLink(_ url: URL) -> Route? {
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return parsePathComponents(path, parameters: url.queryParameters)
    }

    private func parsePathComponents(_ path: String, parameters: [String: String]) -> Route? {
        let components = path.components(separatedBy: "/")

        guard let firstComponent = components.first, !firstComponent.isEmpty else {
            return .home
        }

        switch firstComponent {
        case "home":
            return .home

        case "products":
            // /products/123 → product detail
            if components.count > 1, let productId = Int(components[1]) {
                // In a real app, fetch product from repository
                // For now, use mock product with the ID
                let mockProduct = Product.mockList.first { $0.id == productId } ?? Product.mock
                return .productDetail(mockProduct)
            }
            // /products → product list
            return .productList

        case "favorites":
            return .favorites

        case "orders":
            return .orders

        case "reviews":
            return .reviews

        default:
            return nil
        }
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
