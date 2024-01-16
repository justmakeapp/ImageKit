//
//  ImageCommand.swift
//
//
//  Created by longvu on 16/01/2024.
//

import Foundation

public protocol ImageCommand {
    func execute() async -> Bool
    func cancel()
}
