//
//  Product.swift
//  Ios-MVVM
//
//  Domain model for Product
//

import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: Rating

    struct Rating: Codable, Hashable {
        let rate: Double
        let count: Int
    }
}

// MARK: - Mock Data for Testing
extension Product {
    static let mock = Product(
        id: 1,
        title: "Sample Product",
        price: 29.99,
        description: "This is a sample product description.",
        category: "electronics",
        image: "https://via.placeholder.com/200",
        rating: Rating(rate: 4.5, count: 120)
    )

    static let mockList = [
        Product(
            id: 1,
            title: "Fjallraven - Foldsack No. 1 Backpack",
            price: 109.95,
            description: "Your perfect pack for everyday use and walks in the forest.",
            category: "men's clothing",
            image: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
            rating: Rating(rate: 3.9, count: 120)
        ),
        Product(
            id: 2,
            title: "Mens Casual Premium Slim Fit T-Shirts",
            price: 22.3,
            description: "Slim-fitting style, contrast raglan long sleeve.",
            category: "men's clothing",
            image: "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg",
            rating: Rating(rate: 4.1, count: 259)
        ),
        Product(
            id: 3,
            title: "Mens Cotton Jacket",
            price: 55.99,
            description: "Great outerwear jackets for Spring/Autumn/Winter.",
            category: "men's clothing",
            image: "https://fakestoreapi.com/img/71li-ujtlUL._AC_UX679_.jpg",
            rating: Rating(rate: 4.7, count: 500)
        )
    ]
}
