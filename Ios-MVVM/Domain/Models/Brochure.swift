//
//  Brochure.swift
//  Ios-MVVM
//
//  Domain model for Brochure
//

import Foundation

struct Brochure: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let imageUrl: String
    let pdfUrl: String
    let publishedDate: Date
}

// MARK: - Mock Data for Testing
extension Brochure {
    static let mock = Brochure(
        id: 1,
        title: "Spring Collection 2024",
        description: "Explore our latest spring collection featuring fresh designs and vibrant colors.",
        category: "Seasonal",
        imageUrl: "https://via.placeholder.com/400x600",
        pdfUrl: "https://example.com/spring-2024.pdf",
        publishedDate: Date()
    )

    static let mockList = [
        Brochure(
            id: 1,
            title: "Spring Collection 2024",
            description: "Explore our latest spring collection featuring fresh designs and vibrant colors.",
            category: "Seasonal",
            imageUrl: "https://via.placeholder.com/400x600",
            pdfUrl: "https://example.com/spring-2024.pdf",
            publishedDate: Date().addingTimeInterval(-86400 * 30)
        ),
        Brochure(
            id: 2,
            title: "Summer Sale",
            description: "Amazing discounts on all summer items. Don't miss out on these incredible deals!",
            category: "Promotional",
            imageUrl: "https://via.placeholder.com/400x600",
            pdfUrl: "https://example.com/summer-sale.pdf",
            publishedDate: Date().addingTimeInterval(-86400 * 15)
        ),
        Brochure(
            id: 3,
            title: "New Arrivals",
            description: "Check out the newest products that just landed in our store.",
            category: "New",
            imageUrl: "https://via.placeholder.com/400x600",
            pdfUrl: "https://example.com/new-arrivals.pdf",
            publishedDate: Date().addingTimeInterval(-86400 * 7)
        ),
        Brochure(
            id: 4,
            title: "Holiday Catalog",
            description: "Your complete guide to holiday shopping with exclusive gift ideas.",
            category: "Seasonal",
            imageUrl: "https://via.placeholder.com/400x600",
            pdfUrl: "https://example.com/holiday-catalog.pdf",
            publishedDate: Date().addingTimeInterval(-86400 * 3)
        )
    ]
}
