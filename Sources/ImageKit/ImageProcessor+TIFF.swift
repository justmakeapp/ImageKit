//
//  ImageProcessor+TIFF.swift
//
//
//  Created by Long Vu on 17/3/24.
//

import Foundation
import ImageIO

public extension ImageProcessor {
    var tiffDictionary: [String: Any]? {
        properties?[kCGImagePropertyTIFFDictionary as String] as? [String: Any]
    }
}
