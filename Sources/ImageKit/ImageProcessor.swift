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
        guard let source else {
            return nil
        }
//        let properties = CGImageSourceCopyProperties(source, nil) as? [String: Any]

        /// lấy image đầu tiền, vì JPEG có thể embed cả thumbnail vào
        guard let firstIndexProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else {
            return nil
        }

        let width: Int = {
            var result: Int?
            let propertyKey = kCGImagePropertyPixelWidth as String
//            if let properties, let width = properties[propertyKey] {
//                return width as? CGFloat
//            }
            if let width = firstIndexProperties[propertyKey] {
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
            if let height = firstIndexProperties[propertyKey] {
                result = height as? Int
            }

            return result ?? 0
        }()

        let orientationKey = kCGImagePropertyOrientation as String
        let orientation = (firstIndexProperties[orientationKey] as? Int) ??
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
    enum ImageSource {
        case data(_ imageData: Data)
        case url(_ url: URL)
    }
}
