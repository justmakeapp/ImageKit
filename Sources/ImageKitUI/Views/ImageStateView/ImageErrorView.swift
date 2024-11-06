//
//  ImageErrorView.swift
//
//
//  Created by Long Vu on 10/6/24.
//

import SwiftUI

public struct ImageErrorView: View {
    public init() {}

    public var body: some View {
        contentView
    }

    private var contentView: some View {
        Rectangle()
            .fill(Color.clear)
            .overlay {
                Group {
                    if #available(iOS 18.0, macOS 15.0, *) {
                        Image(systemName: "photo.badge.exclamationmark")
                    } else {
                        Image("custom.photo.error", bundle: .module)
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
        #if !os(watchOS)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
        #endif
    }
}

#Preview {
    ImageErrorView()
}
