//
//  Image+Ext.swift
//  ImageKit
//
//  Created by Long Vu on 11/12/24.
//

import SwiftUI

extension Image {
    func modifier(
        @ViewBuilder body: (_ content: Self) -> some View
    ) -> some View {
        body(self)
    }
}
