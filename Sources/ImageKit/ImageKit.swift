import Accelerate.vImage
import CoreImage
import Foundation
import ImageIO

public protocol SynchronousImageProcessing {
    func getImageDimension() -> CGSize?
    func getImageFileSize() -> Double?
    func getDecodedImageMemorySize() -> Double?
    func downsampleImage(to dimension: CGSize) throws -> CGImage?
    func downsampleImage(withMaxMemory memory: Double) throws -> CGImage?
    func downsampleImage(scaledWith scale: Double) throws -> CGImage?
}

public final class ImageProcessor: SynchronousImageProcessing {
    private static let bytesPerPixel = 4.0

    private let image: ImageSource
    private var source: CGImageSource?

    public init(image: ImageSource) {
        self.image = image
        initializeImageSource()
    }

    private func initializeImageSource() {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary

        let imageSource: CGImageSource? = {
            switch image {
            case let .url(url):
                return CGImageSourceCreateWithURL(url as CFURL, imageSourceOptions)
            case let .data(imageData):
                return CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions)
            }
        }()

        self.source = imageSource
    }

    public func getImageDimension() -> CGSize? {
        guard let source else {
            return nil
        }
        let properties = CGImageSourceCopyProperties(source, nil) as? [String: Any]
        let firstIndexProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]

        let width: CGFloat? = {
            let propertyKey = kCGImagePropertyPixelWidth as String
            if let properties, let width = properties[propertyKey] {
                return width as? CGFloat
            }
            if let firstIndexProperties, let width = firstIndexProperties[propertyKey] {
                return width as? CGFloat
            }
            return nil
        }()

        let height: CGFloat? = {
            let propertyKey = kCGImagePropertyPixelHeight as String
            if let properties, let height = properties[propertyKey] {
                return height as? CGFloat
            }
            if let firstIndexProperties, let height = firstIndexProperties[propertyKey] {
                return height as? CGFloat
            }
            return nil
        }()

        guard let width, let height else {
            return nil
        }
        return CGSize(width: width, height: height)
    }

    public func getImageFileSize() -> Double? {
        guard let source, let properties = CGImageSourceCopyProperties(source, nil) as? [String: Any] else {
            return nil
        }

        return properties[kCGImagePropertyFileSize as String] as? Double
    }

    public func getDecodedImageMemorySize() -> Double? {
        guard let dimension = getImageDimension() else {
            return nil
        }
        return Self.bytesPerPixel * dimension.width * dimension.height
    }

    public func getCGImage() -> CGImage? {
        guard let source else {
            return nil
        }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }

    public func downsampleImage(to dimension: CGSize) throws -> CGImage? {
        guard dimension.width > 0, dimension.height > 0 else {
            let error = NSError(
                domain: "",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Width and height must be positive number"]
            )
            throw error
        }
        guard let source, let initialSize = getImageDimension() else {
            return nil
        }

        if dimension.width > initialSize.width || dimension.height > initialSize.height {
            return getCGImage()
        }

        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: max(dimension.width, dimension.height)
        ] as CFDictionary

        let downsamplingImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions)
        return downsamplingImage
    }

    public func downsampleImage(withMaxMemory memory: Double) throws -> CGImage? {
        guard memory > 0 else {
            let error = NSError(
                domain: "",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Memory size must be positive number"]
            )
            throw error
        }

        guard source != nil, let initialSize = getImageDimension() else {
            return nil
        }

        let ratio = initialSize.width / initialSize.height

        let newHeight = floor(sqrt(memory / Self.bytesPerPixel / ratio))
        let newWidth = floor(ratio * newHeight)

        return try downsampleImage(to: CGSize(width: newWidth, height: newHeight))
    }

    public func downsampleImage(scaledWith scale: Double) throws -> CGImage? {
        guard scale > 0 else {
            let error = NSError(
                domain: "",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Scale must be positive number"]
            )
            throw error
        }

        guard source != nil, let initialSize = getImageDimension() else {
            return nil
        }

        let normalizedScale = min(scale, 1.0)

        let newWidth = floor(initialSize.width * normalizedScale)
        let newHeight = floor(initialSize.height * normalizedScale)

        return try downsampleImage(to: CGSize(width: newWidth, height: newHeight))
    }
}

public extension ImageProcessor {
    enum ImageSource {
        case data(_ imageData: Data)
        case url(_ url: URL)
    }
}
