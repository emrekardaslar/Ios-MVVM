//
//  BrochuresView.swift
//  Ios-MVVM
//
//  Brochures screen for the Brochure activity
//

import SwiftUI

struct BrochuresView: View {
    @StateObject var viewModel: BrochuresViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.brochures) { brochure in
                    BrochureCard(brochure: brochure)
                        .onTapGesture {
                            viewModel.didSelectBrochure(brochure)
                        }
                }
            }
            .padding()
        }
        .navigationTitle("Brochures")
    }
}

// MARK: - Brochure Card Component
struct BrochureCard: View {
    let brochure: Brochure

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: URL(string: brochure.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay {
                        ProgressView()
                    }
            }
            .frame(width: 80, height: 120)
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 8) {
                Text(brochure.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                Text(brochure.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    Text(brochure.category)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)

                    Spacer()
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .padding(.top, 8)
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
        BrochuresView(
            viewModel: BrochuresViewModel(coordinator: nil)
        )
    }
}
