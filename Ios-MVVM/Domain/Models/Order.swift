//
//  Order.swift
//  Ios-MVVM
//
//  Created by Emre Kardaşlar on 20.11.2025.
//


//
//  Order.swift
//  Ios-MVVM
//
//  Domain model for Order
//

import Foundation

struct Order: Identifiable, Hashable, Codable {
    let id: String
    let date: Date
    let status: OrderStatus
    let items: [OrderItem]
    let total: Double

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var formattedTotal: String {
        String(format: "$%.2f", total)
    }
}

struct OrderItem: Identifiable, Hashable, Codable {
    let id = UUID()
    let productName: String
    let quantity: Int
    let price: Double
}

enum OrderStatus: String, Hashable, Codable {
    case pending = "Pending"
    case processing = "Processing"
    case shipped = "Shipped"
    case delivered = "Delivered"
    case cancelled = "Cancelled"

    var color: String {
        switch self {
        case .pending: return "orange"
        case .processing: return "blue"
        case .shipped: return "purple"
        case .delivered: return "green"
        case .cancelled: return "red"
        }
    }
}

// MARK: - Mock Data
extension Order {
    static let mockOrders = [
        Order(
            id: "ORD-001",
            date: Date().addingTimeInterval(-86400 * 2),
            status: .delivered,
            items: [
                OrderItem(productName: "Fjallraven Backpack", quantity: 1, price: 109.95),
                OrderItem(productName: "Mens Cotton Jacket", quantity: 1, price: 55.99)
            ],
            total: 165.94
        ),
        Order(
            id: "ORD-002",
            date: Date().addingTimeInterval(-86400 * 5),
            status: .shipped,
            items: [
                OrderItem(productName: "Casual T-Shirt", quantity: 2, price: 22.30)
            ],
            total: 44.60
        ),
        Order(
            id: "ORD-003",
            date: Date().addingTimeInterval(-86400 * 10),
            status: .processing,
            items: [
                OrderItem(productName: "Premium Headphones", quantity: 1, price: 199.99)
            ],
            total: 199.99
        )
    ]
}
