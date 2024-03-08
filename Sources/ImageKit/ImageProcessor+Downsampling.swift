//
//  ImageProcessor+Downsampling.swift
//
//
//  Created by Long Vu on 04/03/2024.
//

import Foundation
import ImageIO

public extension ImageProcessor {
    func downsampleImage(to dimension: CGSize) throws -> CGImage? {
        guard dimension.width > 0, dimension.height > 0 else {
            let error = NSError(
                domain: "",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Width and height must be positive number"]
            )
            throw error
        }
        guard let source, let initialSize = resolution() else {
            return nil
        }

        if dimension.width > initialSize.width || dimension.height > initialSize.height {
            return getCGImage()
        }

        let downsampleOptions = [
            /// kCGImageSourceCreateThumbnailFromImageAlways indicates that a thumbnail should be created from the image
            /// itself, not from any embedded thumbnail image that might be present.
            kCGImageSourceCreateThumbnailFromImageAlways: true,

            /// When this option is set to true, it instructs the Image I/O framework to decode and cache the image in
            /// full immediately upon creation,
            /// rather than delaying the decoding process until the image is actually rendered or accessed.
            /// Setting this option to true can lead to increased memory usage because the decoded image data is stored
            /// in memory right after the image is created.
            kCGImageSourceShouldCacheImmediately: false,

            /// This option, when set to true, ensures that the thumbnail is generated with the proper orientation based
            /// on the image's EXIF data.
            /// This is particularly useful for images that may have orientation metadata indicating that the image
            /// should be rotated or flipped for correct display.
            kCGImageSourceCreateThumbnailWithTransform: true,

            /// kCGImageSourceThumbnailMaxPixelSize defines the maximum size of the thumbnail's longest dimension,
            /// ensuring the aspect ratio remains unchanged.
            kCGImageSourceThumbnailMaxPixelSize: max(dimension.width, dimension.height)
        ] as CFDictionary

        let downsamplingImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions)
        return downsamplingImage
    }

    func downsampleImage(withMaxMemory memory: Double) throws -> CGImage? {
        guard memory > 0 else {
            let error = NSError(
                domain: "",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Memory size must be positive number"]
            )
            throw error
        }

        guard source != nil, let initialSize = resolution() else {
            return nil
        }

        let ratio = initialSize.width / initialSize.height

        let newHeight = floor(sqrt(memory / Self.bytesPerPixel / ratio))
        let newWidth = floor(ratio * newHeight)

        return try downsampleImage(to: CGSize(width: newWidth, height: newHeight))
    }

    func downsampleImage(scaledWith scale: Double) throws -> CGImage? {
        guard scale > 0 else {
            let error = NSError(
                domain: "",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Scale must be positive number"]
            )
            throw error
        }

        guard source != nil, let initialSize = resolution() else {
            return nil
        }

        let normalizedScale = min(scale, 1.0)

        let newWidth = floor(initialSize.width * normalizedScale)
        let newHeight = floor(initialSize.height * normalizedScale)

        return try downsampleImage(to: CGSize(width: newWidth, height: newHeight))
    }
}
