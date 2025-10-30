//
//  ValidateImageCommand.swift
//  Loop
//
//  Created by Bình Nguyễn Thanh on 29/09/2022.
//

#if canImport(CoreImage)
    import Foundation

    public final class ValidateImageCommand: ImageCommand {
        private static let bytesPerPixel = 4

        let context: Context

        public init(context: Context) {
            self.context = context
        }

        public func execute() throws {
            let processor = ImageProcessor(image: context.image)
            let fileSize = processor.getImageFileSize()

            checkImageFileSize: do {
                if let maxFileSize = context.maxFileSize {
                    guard let fileSize else {
                        throw ErrorType.readImageError
                    }

                    if fileSize > maxFileSize {
                        throw ErrorType.fileSizeTooBig
                    }
                }
            }

            checkMemorySize: do {
                if let maxMemorySize = context.maxMemorySize {
                    guard let imageSize = processor.resolution(),
                          let memorySize = processor.getDecodedImageMemorySize() else {
                        throw ErrorType.readImageError
                    }

                    if memorySize > maxMemorySize {
                        let scale = sqrt(maxMemorySize / memorySize)
                        throw ErrorType.memorySizeTooBig(maxImageDimension: CGSize(
                            width: imageSize.width * scale,
                            height: imageSize.height * scale
                        ))
                    }
                }
            }
        }

        public func cancel() {}
    }

    public extension ValidateImageCommand {
        struct Context {
            let image: ImageProcessor.ImageSource
            let maxFileSize: FileSize?
            let maxMemorySize: FileSize?

            public init(
                image: ImageProcessor.ImageSource,
                maxFileSize: FileSize? = nil,
                maxMemorySize: FileSize? = nil
            ) {
                self.image = image
                self.maxFileSize = maxFileSize
                self.maxMemorySize = maxMemorySize
            }
        }

        enum ErrorType: Error {
            case readImageError
            case fileSizeTooBig
            case memorySizeTooBig(maxImageDimension: CGSize)
        }
    }
#endif
