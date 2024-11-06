//
//  View+Ext.swift
//  ImageKit
//
//  Created by Long Vu on 6/11/24.
//

import SwiftUI

extension View {
    func transform(_ body: (inout Self) -> Void) -> Self {
        var result = self

        body(&result)

        return result
    }

    func modifier<ModifiedContent: View>(
        @ViewBuilder body: (_ content: Self) -> ModifiedContent
    ) -> ModifiedContent {
        body(self)
    }
}
