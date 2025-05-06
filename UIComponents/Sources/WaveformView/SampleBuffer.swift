//
//  SampleBuffer.swift
//  UIComponents
//
//  Created by Thanh Hai Khong on 15/4/25.
//

import Foundation

public final class SampleBuffer: Sendable {
    let samples: [Float]

    public init(samples: [Float]) {
        self.samples = samples
    }

    public var count: Int {
        samples.count
    }
}
