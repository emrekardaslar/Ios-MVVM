//
//  ProductRepositoryProtocol.swift
//  Ios-MVVM
//
//  Protocol for Product data operations
//

import Foundation

protocol ProductRepositoryProtocol {
    func fetchProducts() async throws -> [Product]
    func fetchProduct(id: Int) async throws -> Product
}
