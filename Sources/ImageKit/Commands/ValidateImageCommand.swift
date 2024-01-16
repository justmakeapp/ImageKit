//
//  ValidateImageCommand.swift
//  Loop
//
//  Created by Bình Nguyễn Thanh on 29/09/2022.
//

import Foundation

public final class ValidateImageCommand: ImageCommand {
    private static let bytesPerPixel = 4

    let context: Context
    private(set) var validationError: ErrorType?

    public init(context: Context) {
        self.context = context
    }

    public func execute() async -> Bool {
        let processor = ImageProcessor(image: context.image)
        let fileSize = processor.getImageFileSize()

        checkImageFileSize: do {
            if let maxFileSize = context.maxFileSize {
                guard let fileSize else {
                    validationError = .readImageError
                    return false
                }

                if fileSize > maxFileSize {
                    validationError = .fileSizeTooBig
                    return false
                }
            }
        }

        checkMemorySize: do {
            if let maxMemorySize = context.maxMemorySize {
                guard let imageSize = processor.getImageDimension(),
                      let memorySize = processor.getDecodedImageMemorySize() else {
                    validationError = .readImageError
                    return false
                }

                if memorySize > maxMemorySize {
                    let scale = sqrt(maxMemorySize / memorySize)
                    validationError =
                        .memorySizeTooBig(maxImageDimension: CGSize(
                            width: imageSize.width * scale,
                            height: imageSize.height * scale
                        ))
                    return false
                }
            }
        }

        return true
    }

    public func cancel() {}
}

public extension ValidateImageCommand {
    struct Context {
        let image: ImageProcessor.ImageSource
        let maxFileSize: FileSize?
        let maxMemorySize: FileSize?

        public init(image: ImageProcessor.ImageSource, maxFileSize: FileSize? = nil, maxMemorySize: FileSize? = nil) {
            self.image = image
            self.maxFileSize = maxFileSize
            self.maxMemorySize = maxMemorySize
        }
    }

    enum ErrorType {
        case readImageError
        case fileSizeTooBig
        case memorySizeTooBig(maxImageDimension: CGSize)
    }
}
