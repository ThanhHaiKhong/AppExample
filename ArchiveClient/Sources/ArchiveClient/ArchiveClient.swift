// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import Foundation
import Zip

@DependencyClient
public struct ArchiveClient: Sendable {
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

extension ArchiveClient: DependencyKey {
    public static var liveValue: ArchiveClient {
        ArchiveClient()
    }
}

extension ArchiveClient: TestDependencyKey {
    public static var testValue: ArchiveClient {
        ArchiveClient()
    }
    
    public static var previewValue: ArchiveClient {
        ArchiveClient()
    }
}

extension DependencyValues {
    public var archiveClient: ArchiveClient {
        get { self[ArchiveClient.self] }
        set { self[ArchiveClient.self] = newValue }
    }
}
