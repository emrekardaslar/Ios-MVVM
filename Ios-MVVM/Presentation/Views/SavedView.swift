//
//  SavedView.swift
//  Ios-MVVM
//
//  Saved items screen displaying saved products
//

import SwiftUI

struct SavedView: View {
    @StateObject var viewModel: SavedViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if viewModel.savedItems.isEmpty {
                emptyState
            } else {
                savedItemsList
            }
        }
        .navigationTitle("Saved Items")
    }

    private var loadingView: some View {
        VStack {
            ProgressView("Loading saved items...")
        }
    }

    private var savedItemsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.savedItems) { product in
                    SavedItemRow(product: product) {
                        viewModel.didSelectItem(product)
                    } onRemove: {
                        viewModel.removeItem(product)
                    }
                }
            }
            .padding()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Saved Items")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Items you save for later will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - Saved Item Row Component
struct SavedItemRow: View {
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
                    Image(systemName: "bookmark.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
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
        SavedView(
            viewModel: SavedViewModel(coordinator: nil)
        )
    }
}
