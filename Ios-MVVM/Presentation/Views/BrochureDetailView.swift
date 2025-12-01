//
//  BrochureDetailView.swift
//  Ios-MVVM
//
//  Brochure detail screen displaying full brochure information
//

import SwiftUI

struct BrochureDetailView: View {
    @StateObject var viewModel: BrochureDetailViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading brochure...")
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text("Error")
                        .font(.headline)
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else if let brochure = viewModel.brochure {
                ScrollView {
                    VStack(spacing: 24) {
                        brochureImage(brochure)

                        brochureInfo(brochure)

                        actionButtons

                        Spacer()
                    }
                    .padding()
                }
                .navigationTitle(brochure.title)
            }
        }
        .navigationBarTitleDisplayMode(.large)
    }

    private func brochureImage(_ brochure: Brochure) -> some View {
        AsyncImage(url: URL(string: brochure.imageUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            Rectangle()
                .fill(Color(.systemGray5))
                .overlay {
                    ProgressView()
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)
    }

    private func brochureInfo(_ brochure: Brochure) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category Badge
            HStack {
                Text(brochure.category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)

                Spacer()

                Text(viewModel.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Description
            Text(brochure.description)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                viewModel.downloadPDF()
            }) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title3)
                    Text("Download PDF")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            Button(action: {
                viewModel.shareBrochure()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                    Text("Share Brochure")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .foregroundColor(.blue)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BrochureDetailView(
            viewModel: BrochureDetailViewModel(
                brochureId: 1,
                brochureRepository: DIContainer.shared.brochureRepository,
                coordinator: nil
            )
        )
    }
}
