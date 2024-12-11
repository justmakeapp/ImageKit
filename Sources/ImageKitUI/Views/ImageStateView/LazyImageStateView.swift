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
                    imageViewBuilder(image)
                } else {
                    Text("Unknown state")
                }
            case .failure:
                errorViewBuilder()
            }
        } else {
            if state.isLoading {
                placeholderViewBuilder()
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
