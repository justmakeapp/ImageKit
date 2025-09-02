import Accelerate.vImage
import CoreImage
import Foundation
import ImageIO

public protocol SynchronousImageProcessing {
    func resolution() -> CGSize?
    func getImageFileSize() -> Double?
    func getDecodedImageMemorySize() -> Double?
    func downsampleImage(to dimension: CGSize) throws -> CGImage?
    func downsampleImage(withMaxMemory memory: Double) throws -> CGImage?
    func downsampleImage(scaledWith scale: Double) throws -> CGImage?
}

public final class ImageProcessor: SynchronousImageProcessing {
    static let bytesPerPixel = 4.0

    private let image: ImageSource
    private(set) var source: CGImageSource?

    private(set) var _properties: [String: Any]?
    public private(set) var properties: [String: Any]? {
        get {
            if let _properties {
                return _properties
            } else {
                guard
                    let source,
                    /// lấy image đầu tiền, vì JPEG có thể embed cả thumbnail vào
                    let firstIndexProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
                else {
                    return nil
                }
                _properties = firstIndexProperties
                return firstIndexProperties
            }
        }
        set {
            _properties = newValue
        }
    }

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

    public func resolution() -> CGSize? {
        let width: Int = {
            var result: Int?
            let propertyKey = kCGImagePropertyPixelWidth as String
//            if let properties, let width = properties[propertyKey] {
//                return width as? CGFloat
//            }
            if let width = properties?[propertyKey] {
                result = width as? Int
            }
            return result ?? 0
        }()

        let height: Int = {
            var result: Int?

            let propertyKey = kCGImagePropertyPixelHeight as String
//            if let properties, let height = properties[propertyKey] {
//                return height as? CGFloat
//            }
            if let height = properties?[propertyKey] {
                result = height as? Int
            }

            return result ?? 0
        }()

        let orientationKey = kCGImagePropertyOrientation as String
        let orientation = (properties?[orientationKey] as? Int) ??
            1 // Default to 1 if orientation is not specified

        var newWidth = width
        var newHeight = height
        switch orientation {
        case 1, 2, 3, 4:
            break

        case 5, 6, 7, 8:
            // Rotated orientations (5 and 7 are mirrored and rotated, 6 and 8 are rotated 90° or 270°)
            newWidth = height
            newHeight = width

        default:
            break
        }

        return CGSize(width: newWidth, height: newHeight)
    }

    public var megapixels: Double? {
        // Image DPI for calculating megapixels
        let dpiWidth = properties?[kCGImagePropertyDPIWidth as String] as? CGFloat ?? 72
        let dpiHeight = properties?[kCGImagePropertyDPIHeight as String] as? CGFloat ?? 72

        // Calculate megapixels
        if let pixelWidth = properties?[kCGImagePropertyPixelWidth as String] as? CGFloat,
           let pixelHeight = properties?[kCGImagePropertyPixelHeight as String] as? CGFloat {
            let megapixels = (pixelWidth * dpiWidth / 72.0) * (pixelHeight * dpiHeight / 72.0) / 1_000_000.0
            return megapixels
        } else {
            return nil
        }
    }

    public func getImageFileSize() -> Double? {
        guard let source, let properties = CGImageSourceCopyProperties(source, nil) as? [String: Any] else {
            return nil
        }

        return properties[kCGImagePropertyFileSize as String] as? Double
    }

    public func getDecodedImageMemorySize() -> Double? {
        guard let dimension = resolution() else {
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
}

public extension ImageProcessor {
    enum ImageSource: Sendable {
        case data(_ imageData: Data)
        case url(_ url: URL)
    }
}
