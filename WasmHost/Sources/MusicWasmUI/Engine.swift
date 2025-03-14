//
//  Engine.swift
//  WasmHost
//
//  Created by L7Studio on 17/2/25.
//
import AsyncWasm
import SwiftUI
import MusicWasm
import WasmSwiftProtobuf
import OSLog

public struct WasmBuilder {
    public var music: @Sendable () async throws -> MusicWasmProtocol = { fatalError() }
 
    public struct EnvironmentKey: SwiftUI.EnvironmentKey {
        public static let defaultValue = WasmBuilder()
    }
}

extension EnvironmentValues {
    public var wasmBuilder: WasmBuilder {
        get { self[WasmBuilder.EnvironmentKey.self] }
        set {
            self[WasmBuilder.EnvironmentKey.self] = newValue
        }
    }
}

extension WasmBuilder {
    public static let live = WasmBuilder {
        var ret = try await MusicWasm.music()
        ret.premium = true
        return ret
    }
#if DEBUG
    public static let preview = WasmBuilder {
        try await MusicWasm.preview()
    }
#endif
}

@available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
@Observable
public class WasmEngine: @preconcurrency WasmInstanceDelegate {
    public var state = EngineState.stopped
    var instance: MusicWasmProtocol?
    let defaults = UserDefaults.standard
    
    public init() throws {
    }

    public func set(opts: MusicOptions, version: EngineVersion? = nil) async throws {
        var copts = self.instance?.copts ?? [:]
        copts["music"] = try opts.serializedData()
        self.instance?.copts = copts
    }
    public func suggestion(keyword: String, version: EngineVersion? = nil) async throws -> MusicListSuggestions? {
        try await self.instance?.suggestion(keyword: keyword)
    }
    public func search(keyword: String, scope: String, continuation: String?, version: EngineVersion? = nil) async throws -> MusicListTracks? {
        try await self.instance?.search(keyword: keyword, scope: scope, continuation: continuation)
    }
    public func musicOptions(version: EngineVersion? = nil) async throws -> MusicListOptions? {
        try await self.instance?.options()
    }
    public func discover(category: String, continuation: String?, version: EngineVersion? = nil) async throws -> MusicListTracks? {
        try await self.instance?.discover(category: category, continuation: continuation)
    }
    public func details(vid: String, version: EngineVersion? = nil) async throws -> MusicTrackDetails? {
        try await self.instance?.details(vid: vid)
    }
    public func tracks(pid: String, continuation: String?, version: EngineVersion? = nil) async throws -> MusicListTracks? {
        try await self.instance?.tracks(pid: pid, continuation: continuation)
    }
    
    /// Load engine actor
    /// - Parameters:
    ///   - builder: engine builder
    public func load(with builder: WasmBuilder) async throws {
        guard self.instance == nil else { return }
        self.instance = try await builder.music()
        self.instance?.delegate = self
        try await self.instance?.start()
    }
    @MainActor
    public func stateChanged(state: AsyncWasm.EngineState) {
        debugPrint("state ---> \(state)")
        self.state = state
    }
}
