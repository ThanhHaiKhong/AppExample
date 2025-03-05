//
//  Updater.swift
//  app
//
//  Created by L7Studio on 4/2/25.
//

import AsyncWasm
import OSLog
import SwiftUI
import WasmSwiftProtobuf

@available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
@Observable
public class Updater {
    
    public enum ViewState {
        case initializing, initialized(EngineVersion), downloading(EngineVersion, Double), done(EngineVersion), failed(Error)
    }
    
    public var state: ViewState = .initializing
    
    public func download(version: EngineVersion) async throws {
        guard !version.isEmbedded else {
            await MainActor.run {
                self.state = .done(version)
            }
            return
        }
        if let url = URL(string: version.url) {
            let dst = URL.wasmDir.appending(component: "\(version.id).wasm")
            guard !FileManager.default.fileExists(atPath: dst.path) else {
                await MainActor.run {
                    self.state = .done(version)
                }
                return
            }
            await MainActor.run {
                self.state = .downloading(version, 0)
            }
            let downloader = AsyncDownloaderSession.shared.download(url: url, destination: dst)
            for try await event in downloader.events {
                switch event {
                case let .progress(currentBytes, totalBytes):
                    await MainActor.run {
                        self.state = .downloading(version, Double(currentBytes) / Double(totalBytes))
                    }
                case .success:
                    await MainActor.run {
                        self.state = .done(version)
                    }
                }
            }
        }
    }
    
    public func exist(for version: EngineVersion) -> Bool {
        guard let url = self.url(for: version) else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    public func remove(for version: EngineVersion) async throws {
        guard let url = url(for: version) else { return }
        if url.path.hasPrefix(URL.wasmDir.path) {
            WALogger.host.debug("remove wasm version \(version.id) at \(url)")
            try FileManager.default.removeItem(at: url)
        }
    }
    
    public func url(for version: EngineVersion) -> URL? {
        return version.isEmbedded ? URL(string: version.url) : URL.wasmDir.appending(component: "\(version.id).wasm")
    }
    
    public func load() throws {
        state = .initializing
        if !FileManager.default.fileExists(atPath: URL.wasmDir.path) {
            try FileManager.default.createDirectory(at: URL.wasmDir, withIntermediateDirectories: true)
        }
    }
    
    public func initialize(version: EngineVersion) async throws {
        if version.isEmbedded {
            // Copy the embedded file to the WASM directory.
            if let url = URL(string: version.url), url.isFileURL {
                let dst = URL.wasmDir.appending(component: "\(version.id).wasm")
                guard !FileManager.default.fileExists(atPath: dst.path) else {
                    return
                }
                try FileManager.default.copyItem(at: url, to: dst)
            }
        }
    }
}
