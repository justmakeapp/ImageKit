//
//  FileSize.swift
//  Loop
//
//  Created by Bình Nguyễn Thanh on 29/09/2022.
//

import Foundation

public typealias FileSize = Double

public extension FileSize {
    static func kilobytes(_ num: Double) -> FileSize {
        return num * 1_024.0
    }

    static func megabytes(_ num: Double) -> FileSize {
        return num * 1_048_576.0
    }
}
