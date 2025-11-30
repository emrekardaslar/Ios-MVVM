//
//  FavoritesView.swift
//  Ios-MVVM
//
//  Favorites screen displaying saved products
//

import SwiftUI

struct FavoritesView: View {
    @StateObject var viewModel: FavoritesViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading favorites...")
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text("Error")
                        .font(.headline)
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        viewModel.retry()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else if viewModel.favoriteProducts.isEmpty {
                emptyState
            } else {
                favoritesList
            }
        }
        .navigationTitle("Favorites")
    }

    private var favoritesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.favoriteProducts) { product in
                    FavoriteProductRow(product: product) {
                        viewModel.didSelectProduct(product)
                    } onRemove: {
                        viewModel.removeFavorite(product)
                    }
                }
            }
            .padding()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start adding products to your favorites to see them here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - Favorite Product Row Component
struct FavoriteProductRow: View {
    let product: Product
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: product.image)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                VStack(alignment: .leading, spacing: 8) {
                    Text(product.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(String(format: "$%.2f", product.price))
                        .font(.headline)
                        .foregroundColor(.blue)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", product.rating.rate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        FavoritesView(
            viewModel: FavoritesViewModel(
                favoritesRepository: DIContainer.shared.favoritesRepository,
                coordinator: nil
            )
        )
    }
}
