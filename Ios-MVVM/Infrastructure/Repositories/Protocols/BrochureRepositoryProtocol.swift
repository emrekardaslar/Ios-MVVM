//
//  BrochureRepositoryProtocol.swift
//  Ios-MVVM
//
//  Protocol for Brochure data operations
//

import Foundation

protocol BrochureRepositoryProtocol {
    func fetchBrochures() async throws -> [Brochure]
    func fetchBrochure(id: Int) async throws -> Brochure
}
