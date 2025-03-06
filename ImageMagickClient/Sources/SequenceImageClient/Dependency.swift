//
//  File.swift
//  ImageMagickClient
//
//  Created by Thanh Hai Khong on 6/3/25.
//

import ComposableArchitecture

extension DependencyValues {
    public var sequenceImageClient: SequenceImageClient {
        get { self[SequenceImageClient.self] }
        set { self[SequenceImageClient.self] = newValue }
    }
}
