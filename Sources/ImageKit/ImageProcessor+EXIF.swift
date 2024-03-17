//
//  ImageProcessor+EXIF.swift
//
//
//  Created by Long Vu on 17/3/24.
//

import Foundation
import ImageIO

public extension ImageProcessor {
    var exifDictionary: [String: Any]? {
        properties?[kCGImagePropertyExifDictionary as String] as? [String: Any]
    }
}
