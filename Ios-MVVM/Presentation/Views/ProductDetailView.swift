//
//  ProductDetailView.swift
//  Ios-MVVM
//
//  SwiftUI view displaying detailed product information
//

import SwiftUI

struct ProductDetailView: View {
    @StateObject var viewModel: ProductDetailViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading product...")
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text("Error")
                        .font(.headline)
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else if let product = viewModel.product {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        productImage(product)

                        VStack(alignment: .leading, spacing: 12) {
                            categoryBadge(product)

                            productTitle(product)

                            priceAndRating(product)

                            Divider()

                            descriptionSection(product)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func productImage(_ product: Product) -> some View {
        AsyncImage(url: URL(string: product.image)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(Color(.systemGray6))
    }

    private func categoryBadge(_ product: Product) -> some View {
        Text(product.category.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
    }

    private func productTitle(_ product: Product) -> some View {
        Text(product.title)
            .font(.title2)
            .fontWeight(.bold)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func priceAndRating(_ product: Product) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Text(viewModel.formattedPrice)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(product.rating.rate) ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }

                Text("(\(product.rating.count) reviews)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func descriptionSection(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)

            Text(product.description)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProductDetailView(
            viewModel: ProductDetailViewModel(
                productId: 1,
                productRepository: DIContainer.shared.productRepository,
                coordinator: nil
            )
        )
    }
}
