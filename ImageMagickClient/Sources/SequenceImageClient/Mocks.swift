//
//  File.swift
//  ImageMagickClient
//
//  Created by Thanh Hai Khong on 6/3/25.
//

import ComposableArchitecture

extension SequenceImageClient: TestDependencyKey {
    public static var testValue: Self {
        Self()
    }
    
    public static var previewValue: Self {
        Self()
    }
}
