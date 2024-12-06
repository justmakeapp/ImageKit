//
//  NumberOnMac.swift
//  ImageKit
//
//  Created by Long Vu on 6/12/24.
//

import Foundation

extension CGFloat {
    func scaledToMac() -> CGFloat {
        #if targetEnvironment(macCatalyst) || os(macOS)
            return ceil(self * 0.765)
        #else
            return self
        #endif
    }

    func onMac(_ value: CGFloat) -> CGFloat {
        #if targetEnvironment(macCatalyst) || os(macOS)
            return value
        #else
            return self
        #endif
    }
}

extension Int {
    func scaledToMac() -> Int {
        #if targetEnvironment(macCatalyst) || os(macOS)
            return Int(ceil(Double(self) * 0.765))
        #else
            return self
        #endif
    }

    func onMac(_ value: Int) -> Int {
        #if targetEnvironment(macCatalyst) || os(macOS)
            return value
        #else
            return self
        #endif
    }
}

extension Double {
    func scaledToMac() -> Double {
        #if targetEnvironment(macCatalyst) || os(macOS)
            return ceil(self * 0.765)
        #else
            return self
        #endif
    }

    func onMac(_ value: Double) -> Double {
        #if targetEnvironment(macCatalyst) || os(macOS)
            return value
        #else
            return self
        #endif
    }
}
