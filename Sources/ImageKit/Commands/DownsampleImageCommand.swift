//
//  DownsampleImageCommand.swift
//  Loop
//
//  Created by Bình Nguyễn Thanh on 02/10/2022.
//

import Foundation
import ImageIO

public final class DownsampleImageCommand: ImageCommand, Sendable {
    let context: Context

    public init(context: Context) {
        self.context = context
    }

    public func execute() async -> Data? {
        let processor = ImageProcessor(image: context.image)
        guard
            let initialSize = processor.resolution(),
            let initialMemorySize = processor.getDecodedImageMemorySize()
        else {
            return nil
        }

        let scale: Double = {
            var scale = 1.0
            if let maxMemorySize = context.maxMemorySize {
                scale = min(scale, sqrt(maxMemorySize / initialMemorySize))
            }
            if let maxDimensionSize = context.maxDimensionSize {
                scale = min(
                    scale,
                    maxDimensionSize.width / initialSize.width,
                    maxDimensionSize.height / initialSize.height
                )
            }
            return max(scale, 0)
        }()

        guard let newImage = try? processor.downsampleImage(scaledWith: scale) else {
            return nil
        }

        guard let data = newImage.jpegData(compressionQuality: min(1.0, context.compressionQuality)) else {
            return nil
        }

        return data
    }

    public func cancel() {}
}

public extension DownsampleImageCommand {
    struct Context: Sendable {
        let image: ImageProcessor.ImageSource
        let maxMemorySize: FileSize?
        let maxDimensionSize: CGSize?
        let compressionQuality: Double

        public init(
            image: ImageProcessor.ImageSource,
            maxMemorySize: FileSize? = nil,
            maxDimensionSize: CGSize? = nil,
            compressionQuality: Double = 1
        ) {
            self.image = image
            self.maxMemorySize = maxMemorySize
            self.maxDimensionSize = maxDimensionSize
            self.compressionQuality = compressionQuality
        }
    }
}
