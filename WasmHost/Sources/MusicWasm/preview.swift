//
//  preview.swift
//  WasmHost
//
//  Created by L7Studio on 13/2/25.
//
import Foundation
import AsyncWasm
import WasmSwiftProtobuf

#if DEBUG
public func preview() async throws -> MusicWasmProtocol {
     PreviewWasmEngine()
}

class PreviewWasmEngine: MusicWasmProtocol {
  
    var delegate: (any AsyncWasm.WasmInstanceDelegate)?
    
    var error: Error?
    
    func initialize() async throws -> Data {
        Data()
    }
    
    func options() async throws -> MusicListOptions {
        MusicListOptions()
    }
    
    var premium: Bool = false
    
    var copts: [String : Data] = [:]
    
    func suggestion(keyword: String) async throws -> MusicListSuggestions {
        fatalError()
    }

    func discover(category: String, continuation: String?) async throws -> MusicListTracks {
        fatalError()
    }
    
    var url: URL?
    required init() {
        fatalError()
    }
    required init(file: URL?) throws {
        self.url = file
    }
    func version() async throws -> Data {
        fatalError()
    }
    func start() async throws {
        fatalError()
    }
    func call(_ data: Data) async throws -> Data {
        fatalError()
    }
    func suggestion(keyword: String, hl: String?) async throws -> MusicListSuggestions {
        try await simulate()
        return try MusicListSuggestions(jsonString: """
        {"suggestions":[]}
        """)
    }
    func details(vid: String) async throws -> MusicTrackDetails {
        try await simulate()
        return try MusicTrackDetails(serializedBytes: Data(contentsOf: Bundle.module.url(forResource: "details", withExtension: "dat")!))
    }
    
    func search(keyword: String, scope: String, continuation: String?) async throws -> MusicListTracks {
        try await simulate()
        return try MusicListTracks(serializedBytes: Data(contentsOf: Bundle.module.url(forResource: "search", withExtension: "dat")!))
    }

    func tracks(pid: String, continuation: String?) async throws -> MusicListTracks {
        try await simulate()
        return try MusicListTracks(jsonString: "")
    }

    private func simulate() async throws {
        try await Task.sleep(nanoseconds: UInt64.random(in: 0..<5) * 1_000_000_000)
    }
    func version() async throws -> EngineVersion {
        try await simulate()
        return try EngineVersion(jsonString: """
{"id":"1","name":"1.0","sha":"1837420","next":{"id":"2","name":"2.0","url":"https://wasm.sfo3.cdn.digitaloceanspaces.com/music_1837420.wasm"},"releaseDate":"1970"}
""")
    }
}
#endif
