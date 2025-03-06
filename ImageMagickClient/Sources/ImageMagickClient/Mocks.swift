//
//  File.swift
//  ImageMagickClient
//
//  Created by Thanh Hai Khong on 6/3/25.
//

import ComposableArchitecture

extension ImageMagickClient: TestDependencyKey {
    public static var testValue: ImageMagickClient {
        Self()
    }
    
    public static var previewValue: ImageMagickClient {
        Self()
    }
}
