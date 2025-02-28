//
//  Engine.swift
//  WasmHost
//
//  Created by L7Studio on 17/2/25.
//
import AsyncWasm
import SwiftUI
import MusicWasm
import OSLog
import WasmKit

public struct WasmBuilder {
    public var music: @Sendable (_ url: URL) async throws -> MusicWasmProtocol = {_ in fatalError() }
 
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
    public static let live = WasmBuilder { url in
        var ret = try await MusicWasm.music(url: url)
        ret.premium = true
        return ret
    }
#if DEBUG
    public static let preview = WasmBuilder { url in
        try await MusicWasm.preview(url: url)
    }
#endif
}

actor WasmEngineActor {
    private var wasm: MusicWasmProtocol!
    
    init(url: URL, builder: WasmBuilder) async throws {
        self.wasm = try await builder.music(url)
    }

    func version() async throws -> EngineVersion {
        try await wasm.version()
    }
    func set(opts: MusicOptions) async throws {
        self.wasm.copts["music"] = try opts.serializedData()
    }
    func suggestion(keyword: String) async throws -> MusicListSuggestions {
        try await wasm.suggestion(keyword: keyword)
    }
    func search(keyword: String, scope: String, continuation: String?) async throws -> MusicListTracks {
        try await wasm.search(keyword: keyword, scope: scope, continuation: continuation)
    }
    func musicOptions() async throws -> MusicListOptions {
        try await wasm.options()
    }
    func discover(category: String, continuation: String?) async throws -> MusicListTracks {
        try await wasm.discover(category: category, continuation: continuation)
    }
    func details(vid: String) async throws -> MusicTrackDetails {
        try await wasm.details(vid: vid)
    }
    func tracks(pid: String, continuation: String?) async throws -> MusicListTracks {
        try await wasm.tracks(pid: pid, continuation: continuation)
    }
}

@available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
@Observable
public class WasmEngine {
    public let updater = Updater()
    var actors: [String: WasmEngineActor] = [:]
    let defaults = UserDefaults.standard
    
    @ObservationIgnored
    @AppStorage("selected_version")
    private var selected: EngineVersion?
    
    public init() throws {
        try updater.load()
        WALogger.host.debug("[engine] selected \(self.selected?.id ?? "nil")")
    }
    
    func actor(for version: EngineVersion?) -> WasmEngineActor? {
        return self.actors[(version ?? selected ?? EngineVersion.embedded()).id]
    }
    public func checkUpdate(version: EngineVersion? = nil) async throws -> EngineVersion {
        try await self.actor(for: version)?.version() ?? EngineVersion.embedded()
    }

    public func set(opts: MusicOptions, version: EngineVersion? = nil) async throws {
        try await self.actor(for: version)?.set(opts: opts)
    }
    public func suggestion(keyword: String, version: EngineVersion? = nil) async throws -> MusicListSuggestions? {
        try await self.actor(for: version)?.suggestion(keyword: keyword)
    }
    public func search(keyword: String, scope: String, continuation: String?, version: EngineVersion? = nil) async throws -> MusicListTracks? {
        try await self.actor(for: version)?.search(keyword: keyword, scope: scope, continuation: continuation)
    }
    public func musicOptions(version: EngineVersion? = nil) async throws -> MusicListOptions? {
        try await self.actor(for: version)?.musicOptions()
    }
    public func discover(category: String, continuation: String?, version: EngineVersion? = nil) async throws -> MusicListTracks? {
        try await self.actor(for: version)?.discover(category: category, continuation: continuation)
    }
    public func details(vid: String, version: EngineVersion? = nil) async throws -> MusicTrackDetails? {
        try await self.actor(for: version)?.details(vid: vid)
    }
    public func tracks(pid: String, continuation: String?, version: EngineVersion? = nil) async throws -> MusicListTracks? {
        try await self.actor(for: version)?.tracks(pid: pid, continuation: continuation)
    }
    
    /// Load engine actor
    /// - Parameters:
    ///   - builder: engine builder
    ///   - version: If the version is not available, use the selected or embedded version.
    public func load(with builder: WasmBuilder, version: EngineVersion?) async throws {
        let val = version ?? selected ?? EngineVersion.embedded()
        if updater.exist(for: val) {
            if let url = updater.url(for: val) {
                if actors.keys.contains(val.id) { return }
                if !val.isEmbedded {
                    self.selected = val
                }
                
                defer { WALogger.host.debug("loaded actor for version \(val.id)") }
                actors[val.id] = try await WasmEngineActor(url: url, builder: builder)
            }
        }
    }
    
    public func remove(for version: EngineVersion) async throws {
        WALogger.host.debug("remove version \(version.id)")
        if self.selected?.id == version.id {
            self.selected = nil
        }
        try await updater.remove(for: version)
        defer { WALogger.host.debug("unloaded actor for version \(version.id)") }
        self.actors.removeValue(forKey: version.id)
    }
}
