//
//  ImageProcessor+EXIF.swift
//
//
//  Created by Long Vu on 17/3/24.
//

#if canImport(CoreImage)
    import Foundation
    import ImageIO

    public extension ImageProcessor {
        private var exifDictionary: [String: Any]? {
            properties?[kCGImagePropertyExifDictionary as String] as? [String: Any]
        }

        var exif: Exif {
            Exif(exifDictionary: exifDictionary)
        }
    }

    public struct Exif {
        private static let creationDateFormatter: DateFormatter = {
            let v = DateFormatter()
            v.dateFormat = "yyyy:MM:dd HH:mm:ss"
            return v
        }()

        var exifDictionary: [String: Any]?
    }

    public extension Exif {
        var creationDate: Date? {
            guard let dateString = exifDictionary?[kCGImagePropertyExifDateTimeOriginal as String] as? String else {
                return nil
            }

            guard let date = Self.creationDateFormatter.date(from: dateString) else {
                return nil
            }

            return date
        }

        var lensModel: String? {
            exifDictionary?[kCGImagePropertyExifLensModel as String] as? String
        }

        var iso: [Int] {
            let v = exifDictionary?[kCGImagePropertyExifISOSpeedRatings as String] as? [Int]
            return v ?? []
        }

        var focalLengthIn35mmFormat: Double? {
            exifDictionary?[kCGImagePropertyExifFocalLenIn35mmFilm as String] as? Double
        }

        var fNumber: Double? {
            exifDictionary?[kCGImagePropertyExifFNumber as String] as? Double
        }

        var exposureCompensation: Double? {
            exifDictionary?[kCGImagePropertyExifExposureBiasValue as String] as? Double
        }

        var shutterSpeedValue: Double? {
            guard let shutterSpeedValue = exifDictionary?[kCGImagePropertyExifShutterSpeedValue as String] as? Double
            else {
                return nil
            }
            return pow(2.0, shutterSpeedValue)
        }
    }
#endif
