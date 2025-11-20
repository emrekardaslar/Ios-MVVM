//
//  ProductListView.swift
//  Ios-MVVM
//
//  SwiftUI view displaying list of products
//

import SwiftUI

struct ProductListView: View {
    @StateObject var viewModel: ProductListViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading products...")
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage, retryAction: viewModel.retry)
            } else {
                productGrid
            }
        }
        .navigationTitle("Products")
        .task {
            await viewModel.loadProducts()
        }
    }

    private var productGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(viewModel.products) { product in
                    ProductCard(product: product)
                        .onTapGesture {
                            viewModel.didSelectProduct(product)
                        }
                }
            }
            .padding()
        }
    }
}

// MARK: - Product Card Component
struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: product.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.subheadline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack {
                    Text(String(format: "$%.2f", product.price))
                        .font(.headline)
                        .foregroundColor(.blue)

                    Spacer()

                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", product.rating.rate))
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Error View Component
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)

            Text(message)
                .multilineTextAlignment(.center)
                .padding()

            Button("Retry") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProductListView(
            viewModel: ProductListViewModel(
                productRepository: MockProductRepository(),
                coordinator: nil
            )
        )
    }
}
