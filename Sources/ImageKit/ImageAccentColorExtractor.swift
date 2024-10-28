//
//  ImageAccentColorExtractor.swift
//  AppHomeKit
//
//  Created by Long Vu on 27/10/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

public class ImageAccentColorExtractor {
    public static func accentColor(for image: PlatformImage) -> Color? {
        #if os(iOS)
            guard let ciImage = CIImage(image: image) else { return nil }
        #elseif os(macOS)
            guard let tiffData = image.tiffRepresentation,
                  let bitmapRep = NSBitmapImageRep(data: tiffData),
                  let ciImage = CIImage(bitmapImageRep: bitmapRep) else { return nil }
        #endif

        // Use CIAreaAverage filter to get the average color
        let filter = CIFilter.areaAverage()
        filter.inputImage = ciImage
        filter.extent = ciImage.extent

        guard let outputImage = filter.outputImage else {
            return nil
        }

        // Render the output image to a 1x1 pixel
        let context = CIContext()
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        // Convert bitmap to Color
        return Color(
            red: Double(bitmap[0]) / 255.0,
            green: Double(bitmap[1]) / 255.0,
            blue: Double(bitmap[2]) / 255.0,
            opacity: Double(bitmap[3]) / 255.0
        )
    }
}
