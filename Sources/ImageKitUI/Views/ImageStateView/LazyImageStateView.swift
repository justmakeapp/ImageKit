//
//  LazyImageStateView.swift
//  ConversationKit
//
//  Created by Long Vu on 31/10/24.
//

import NukeUI
import SwiftUI

public struct LazyImageStateView<ImageView: View, ErrorView: View, PlaceholderView: View>: View {
    /// A copy of the state, not the state itself: Nuke's state is one object that stays the same while it loads, so
    /// SwiftUI could see no change, skip redrawing this view, and keep showing nothing after the image arrived.
    private let phase: Phase

    let imageViewBuilder: (Image) -> ImageView
    let errorViewBuilder: () -> ErrorView
    let placeholderViewBuilder: () -> PlaceholderView

    public init(
        _ state: LazyImageState,
        @ViewBuilder imageViewBuilder: @escaping (Image) -> ImageView = { $0.resizable().scaledToFill() },
        @ViewBuilder errorViewBuilder: @escaping () -> ErrorView = {
            ImageErrorView()
                .maxSize(CGSize(width: CGFloat.infinity, height: CGFloat.infinity))
                .resizable(false)
        },
        @ViewBuilder placeholderViewBuilder: @escaping () -> PlaceholderView = {
            ImagePlaceholderView()
                .maxSize(CGSize(width: CGFloat.infinity, height: CGFloat.infinity))
                .resizable(false)
        }
    ) {
        self.phase = Phase(state)
        self.imageViewBuilder = imageViewBuilder
        self.errorViewBuilder = errorViewBuilder
        self.placeholderViewBuilder = placeholderViewBuilder
    }

    public var body: some View {
        contentView
    }

    @ViewBuilder
    private var contentView: some View {
        switch phase {
        case let .success(image):
            if let image {
                imageViewBuilder(image)
            } else {
                Text("Unknown state")
            }

        case .failure:
            errorViewBuilder()

        case .loading:
            placeholderViewBuilder()

        case .idle:
            EmptyView()
        }
    }
}

private extension LazyImageStateView {
    enum Phase {
        case idle
        case loading
        case success(Image?)
        case failure

        @MainActor
        init(_ state: LazyImageState) {
            switch state.result {
            case .success:
                self = .success(state.image)
            case .failure:
                self = .failure
            case nil:
                self = state.isLoading ? .loading : .idle
            }
        }
    }
}

#Preview {
    let imageUrl =
        URL(string: "https://c4.wallpaperflare.com/wallpaper/217/501/151/light-lamp-latern-hd-wallpaper-preview.jpg")

    LazyImage(request: ImageRequest(
        url: imageUrl,
        processors: [
            //                    ImageProcessors.Resize(width: config.imageSize.width)
        ],
        userInfo: [:
            //                    ImageRequest.UserInfoKey.thumbnailKey: ImageRequest.ThumbnailOptions(
            //                        size: .init(width: config.imageSize.width, height: config.imageSize.height),
            //                        unit: .points
            //                    )
        ]
    )) { state in
        LazyImageStateView(state)
    }
    .frame(width: 200, height: 200)
}
