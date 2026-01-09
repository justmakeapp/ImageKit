//
//  ImageErrorView.swift
//
//
//  Created by Long Vu on 10/6/24.
//

import SwiftUI

public struct ImageErrorView: View {
    @Environment(\.colorScheme) private var colorScheme

    private var config = Config()

    public init() {}

    public var body: some View {
        contentView
    }

    private var contentView: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(maxWidth: config.maxSize.width, maxHeight: config.maxSize.height)
            .overlay {
                imageView
                    .modifier {
                        if colorScheme == .light {
                            $0.foregroundStyle(.tertiary)
                        } else {
                            $0.foregroundStyle(.gray.opacity(0.6))
                        }
                    }
            }
            .modifier { content in
                if config.useBackground {
                    content
                    #if !os(watchOS)
                    .background(
                        .ultraThinMaterial,
                        in: .rect(cornerRadius: min(config.maxSize.width / 6, config.cornerRadius))
                    )
                    #endif

                } else {
                    content
                }
            }
    }

    private var imageView: some View {
        image
            .modifier { content in
                if config.resizable {
                    content
                        .resizable()
                        .scaledToFit()
                } else {
                    content
                        .font(config.font)
                        .imageScale(config.imageScale)
                }
            }
            .modifier { content in
                if #available(iOS 18.0, macOS 15.0, watchOS 11.0, *) {
                    content.symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                } else if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
                    content.symbolEffect(.pulse, options: .nonRepeating)
                } else {
                    content
                }
            }
    }

    private var image: Image {
        if #available(iOS 18.0, macOS 15.0, *) {
            Image(systemName: "photo.badge.exclamationmark")
        } else {
            Image("custom.photo.error", bundle: .module)
//            Image(systemName: "photo")
        }
    }
}

public extension ImageErrorView {
    struct Config {
        var maxSize: CGSize = .init(width: 72.scaledToMac(), height: 72.scaledToMac())
        var cornerRadius: CGFloat = 8
        var useBackground: Bool = true
        var resizable: Bool = true
        var font: Font = .largeTitle
        var imageScale: Image.Scale = .large
    }

    func useBackground(_ value: Bool) -> Self {
        transform { $0.config.useBackground = value }
    }

    func cornerRadius(_ value: CGFloat) -> Self {
        transform { $0.config.cornerRadius = value }
    }

    func maxSize(_ value: CGSize) -> Self {
        transform { $0.config.maxSize = value }
    }

    func resizable(_ value: Bool) -> Self {
        transform { $0.config.resizable = value }
    }
}

#if DEBUG
    #Preview {
        HStack {
            Rectangle()
                .fill(Color.green.opacity(0.5))
                .frame(width: 72, height: 72)
                .overlay {
                    ImageErrorView()
                }

            Spacer()

            Rectangle()
                .fill(Color.green.opacity(0.5))
                .frame(width: 16, height: 16)
                .overlay {
                    ImageErrorView()
                }

            Rectangle()
                .fill(Color(red: 255 / 255, green: 246 / 255, blue: 199 / 255))
                .frame(width: 200, height: 100)
                .overlay {
                    ImageErrorView()
                        .useBackground(false)
                }
                .colorScheme(.dark)
        }
        .padding(50)
    }
#endif
