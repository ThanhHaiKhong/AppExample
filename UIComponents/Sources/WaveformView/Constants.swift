//
//  Constants.swift
//  UIComponents
//
//  Created by Thanh Hai Khong on 15/4/25.
//

import Foundation
import SwiftUI

public struct Constants {

    public var color = SIMD4<Float>(1,1,1,1)

    public init(color: Color = .white) {
        self.color = color.components
    }
}
