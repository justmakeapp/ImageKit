//
//  ImagePlaceholderView.swift
//  CommonKitUI
//
//  Created by Long Vu on 31/10/24.
//

import SwiftUI

public struct ImagePlaceholderView: View {
    private var config = Config()

    public init() {}

    public var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(maxWidth: config.maxSize.width, maxHeight: config.maxSize.height)
            .overlay {
                imageView
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
        Image(systemName: "photo")
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
            .foregroundStyle(.tertiary)
            .modifier {
                if #available(iOS 17.0, macOS 14.0, *) {
                    if config.symbolEffectEnabled {
                        $0.symbolEffect(.pulse)
                    } else {
                        $0
                    }
                } else {
                    $0
                }
            }
    }
}

public extension ImagePlaceholderView {
    struct Config {
        var symbolEffectEnabled: Bool = true
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

    func symbolEffectEnabled(_ enabled: Bool = true) -> Self {
        transform { $0.config.symbolEffectEnabled = enabled }
    }

    func maxSize(_ size: CGSize) -> Self {
        transform { $0.config.maxSize = size }
    }

    func resizable(_ value: Bool) -> Self {
        transform { $0.config.resizable = value }
    }
}

#Preview {
    ZStack {
        ImagePlaceholderView()
    }
    .padding()
}
