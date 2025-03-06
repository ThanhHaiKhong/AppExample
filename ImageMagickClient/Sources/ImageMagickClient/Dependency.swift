//
//  File.swift
//  ImageMagickClient
//
//  Created by Thanh Hai Khong on 6/3/25.
//

import ComposableArchitecture

extension DependencyValues {
    public var imageMagickClient: ImageMagickClient {
        get { self[ImageMagickClient.self] }
        set { self[ImageMagickClient.self] = newValue }
    }
}
