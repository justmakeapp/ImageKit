//
//  CGImage+Extension.swift
//
//
//  Created by Bình Nguyễn Thanh on 02/10/2022.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

public extension CGImage {
    func jpegData(compressionQuality: Double = 1.0) -> Data? {
        let data = NSMutableData()
        guard let imageDestination =
            CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil) else {
            return nil
        }

        let properties = [kCGImageDestinationLossyCompressionQuality: min(compressionQuality, 1.0)] as CFDictionary

        CGImageDestinationAddImage(imageDestination, self, properties)
        CGImageDestinationFinalize(imageDestination)
        return data as Data
    }
}
