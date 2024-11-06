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
            .overlay {
                Image(systemName: "photo")
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
        #if !os(watchOS)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
        #endif
    }
}

public extension ImagePlaceholderView {
    struct Config {
        var symbolEffectEnabled: Bool = true
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
