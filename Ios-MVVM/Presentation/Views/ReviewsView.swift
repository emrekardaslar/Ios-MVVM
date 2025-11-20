//
//  ReviewsView.swift
//  Ios-MVVM
//
//  Reviews screen displaying user reviews
//

import SwiftUI

struct ReviewsView: View {
    @StateObject var viewModel: ReviewsViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.reviews) { review in
                    ReviewCard(review: review)
                }
            }
            .padding()
        }
        .navigationTitle("My Reviews")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Review Card Component
struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.productName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(review.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(review.rating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }

                    Text(review.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Comment
            Text(review.comment)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ReviewsView(
            viewModel: ReviewsViewModel(coordinator: nil)
        )
    }
}
