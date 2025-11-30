//
//  FavoritesRepositoryProtocol.swift
//  Ios-MVVM
//
//  Protocol defining favorites data operations
//

import Foundation

protocol FavoritesRepositoryProtocol {
    func fetchFavorites() async throws -> [Product]
    func addFavorite(productId: Int) async throws
    func removeFavorite(productId: Int) async throws
}
