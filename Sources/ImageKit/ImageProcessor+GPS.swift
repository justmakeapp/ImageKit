//
//  ImageProcessor+GPS.swift
//
//
//  Created by Long Vu on 20/4/24.
//

#if canImport(CoreImage)
    import CoreLocation
    import Foundation
    import ImageIO

    public extension ImageProcessor {
        private var gpsDictionary: [String: Any]? {
            properties?[kCGImagePropertyGPSDictionary as String] as? [String: Any]
        }

        var gps: GPS {
            GPS(gps: gpsDictionary ?? [:])
        }
    }

    public extension ImageProcessor {
        struct GPS {
            var gps: [String: Any]
        }
    }

    public extension ImageProcessor.GPS {
        var location: CLLocation? {
            // Extract latitude and longitude
            guard
                let latitude = gps[kCGImagePropertyGPSLatitude as String] as? CLLocationDegrees,
                let longitude = gps[kCGImagePropertyGPSLongitude as String] as? CLLocationDegrees,
                let latitudeRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String,
                let longitudeRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String
            else {
                print("GPS data is incomplete.")
                return nil
            }

            /// Convert latitude and longitude according to their reference (N/S, E/W)
            /// The conversion of latitude and longitude according to their references (N/S for latitude and E/W for
            /// longitude)
            /// is crucial in accurately interpreting GPS coordinates because the raw numbers extracted from
            /// the metadata don't inherently indicate whether they are north or south of the equator, or east or west
            /// of
            /// the Prime Meridian.
            let latMultiplier = (latitudeRef == "N") ? 1.0 : -1.0
            let lonMultiplier = (longitudeRef == "E") ? 1.0 : -1.0

            let location = CLLocation(
                latitude: latitude * latMultiplier,
                longitude: longitude * lonMultiplier
            )

            return location
        }
    }
#endif
