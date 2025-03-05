//
//  Ext.swift
//  WasmHost
//
//  Created by L7Studio on 17/2/25.
//
import AsyncWasm
import SwiftUI
import MusicWasm
import OSLog
import WasmSwiftProtobuf

extension EngineVersion: Identifiable {}

extension MusicTrack: Identifiable {}

extension EngineVersion {
    public var isEmbedded: Bool { self.url.hasSuffix("embedded.wasm")}
}
extension MusicTrack {
    public var isPlaylist: Bool { self.kind.hasSuffix("#playlist") }
}


extension EngineVersion: RawRepresentable {
    public init?(rawValue: String) {
        try? self.init(jsonString: rawValue)
    }
    
    public var rawValue: String {
        try! self.jsonString()
    }
}

@available(iOS 16, macOS 14, tvOS 17, watchOS 10, *)
extension URL {
    static let wasmDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(component: "wasm")
    
    var wasmPath: String {
        path.replacingOccurrences(of: URL.wasmDir.path, with: "")
    }
}

extension EngineVersion {
    static let embedded = {
        let url = Bundle.main.url(forResource: "embedded", withExtension: "wasm")!
        
        return try! Self(jsonString: """
        {"id":"embedded", "name": "embedded", "url": "\(url.absoluteString)"}
        """)
    }
}
