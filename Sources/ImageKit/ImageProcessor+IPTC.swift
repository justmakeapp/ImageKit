//
//  ImageProcessor+IPTC.swift
//
//
//  Created by Long Vu on 17/3/24.
//

import Foundation
import ImageIO

public extension ImageProcessor {
    var iptcDictionary: [String: Any]? {
        properties?[kCGImagePropertyIPTCDictionary as String] as? [String: Any]
    }

    var caption: String? {
        guard
            let caption = iptcDictionary?[kCGImagePropertyIPTCCaptionAbstract as String] as? String
        else {
            return nil
        }

        return caption
    }
}
