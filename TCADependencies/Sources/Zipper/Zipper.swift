//
//  Zipper.swift
//  TCADependencies
//
//  Created by Thanh Hai Khong on 13/1/25.
//

import ComposableArchitecture
import Foundation
import Zip

@DependencyClient
public struct Zipper: Sendable {
    public var zipFiles: @Sendable (_ files: [URL], _ destination: URL, _ password: String?) async throws -> Void = { files, destination, password in
        try Zip.zipFiles(paths: files, zipFilePath: destination, password: password) { progress in
            
        }
    }
    
    public var cleanUp: @Sendable () async throws -> Void = {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory

        let files = try fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
        for file in files {
            if file.pathExtension.contains("zip") {
                try fileManager.removeItem(at: file)
            }
        }
    }
}

extension Zipper: DependencyKey {
    public static var liveValue: Zipper {
        Zipper()
    }
}

extension Zipper: TestDependencyKey {
    public static var testValue: Zipper {
        Zipper()
    }
    
    public static var previewValue: Zipper {
        Zipper()
    }
}

extension DependencyValues {
    public var zipper: Zipper {
        get { self[Zipper.self] }
        set { self[Zipper.self] = newValue }
    }
}
