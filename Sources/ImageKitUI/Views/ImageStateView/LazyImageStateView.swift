//
//  LazyImageStateView.swift
//  ConversationKit
//
//  Created by Long Vu on 31/10/24.
//

import NukeUI
import SwiftUI

public struct LazyImageStateView<ImageView: View, ErrorView: View, PlaceholderView: View>: View {
    let state: LazyImageState

    let imageViewBuilder: (Image) -> ImageView
    let errorViewBuilder: () -> ErrorView
    let placeholderViewBuilder: () -> PlaceholderView

    public init(
        _ state: LazyImageState,
        @ViewBuilder imageViewBuilder: @escaping (Image) -> ImageView = { $0.resizable().scaledToFill() },
        @ViewBuilder errorViewBuilder: @escaping () -> ErrorView = { ImageErrorView() },
        @ViewBuilder placeholderViewBuilder: @escaping () -> PlaceholderView = { ImagePlaceholderView() }
    ) {
        self.state = state
        self.imageViewBuilder = imageViewBuilder
        self.errorViewBuilder = errorViewBuilder
        self.placeholderViewBuilder = placeholderViewBuilder
    }

    public var body: some View {
        contentView
    }

    @ViewBuilder
    private var contentView: some View {
        if let result = state.result {
            switch result {
            case .success:
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Text("Unknown state")
                }
            case .failure:
                ImageErrorView()
            }
        } else {
            if state.isLoading {
                placeholderViewBuilder()
            } else {
                Text("Unknown state")
            }
        }
    }
}
