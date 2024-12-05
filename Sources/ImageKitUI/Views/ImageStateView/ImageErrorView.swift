//
//  ImageErrorView.swift
//
//
//  Created by Long Vu on 10/6/24.
//

import SwiftUI

public struct ImageErrorView: View {
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
                Group {
                    if #available(iOS 18.0, macOS 15.0, *) {
                        Image(systemName: "photo.badge.exclamationmark")
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image("custom.photo.error", bundle: .module)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(.tertiary)
                .modifier {
                    if #available(iOS 18.0, macOS 15.0, *) {
                        $0.symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                    } else if #available(iOS 17.0, macOS 14.0, *) {
                        $0.symbolEffect(.pulse, options: .nonRepeating)
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

public extension ImageErrorView {
    struct Config {
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
}

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
    }
    .padding(50)
}
