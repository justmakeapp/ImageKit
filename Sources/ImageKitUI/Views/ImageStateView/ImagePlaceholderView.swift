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
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .font(.largeTitle)
                    .imageScale(.large)
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
}

public extension ImagePlaceholderView {
    struct Config {
        var symbolEffectEnabled: Bool = true
        var maxSize: CGSize = .init(width: 72, height: 72)
        var cornerRadius: CGFloat = 8
        var useBackground: Bool = true
    }

    func useBackground(_ value: Bool) -> Self {
        transform { $0.config.useBackground = value }
    }

    func cornerRadius(_ value: CGFloat) -> Self {
        transform { $0.config.cornerRadius = value }
    }

    func symbolEffectEnabled(_ enabled: Bool = true) -> ImagePlaceholderView {
        transform { $0.config.symbolEffectEnabled = enabled }
    }
}

#Preview {
    ZStack {
        ImagePlaceholderView()
    }
    .padding()
}
