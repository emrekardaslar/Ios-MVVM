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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                productImage

                VStack(alignment: .leading, spacing: 12) {
                    categoryBadge

                    productTitle

                    priceAndRating

                    Divider()

                    descriptionSection
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var productImage: some View {
        AsyncImage(url: URL(string: viewModel.product.image)) { image in
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

    private var categoryBadge: some View {
        Text(viewModel.product.category.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
    }

    private var productTitle: some View {
        Text(viewModel.product.title)
            .font(.title2)
            .fontWeight(.bold)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var priceAndRating: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(viewModel.formattedPrice)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(viewModel.product.rating.rate) ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }

                Text("(\(viewModel.product.rating.count) reviews)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)

            Text(viewModel.product.description)
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
                product: Product.mock,
                coordinator: nil
            )
        )
    }
}
