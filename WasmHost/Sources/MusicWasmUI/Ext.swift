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

extension EngineVersion {
    static let embedded = {
        let url = Bundle.main.url(forResource: "embedded", withExtension: "wasm")!
        
        return try! Self(jsonString: """
        {"id":"embedded", "name": "embedded", "url": "\(url.absoluteString)"}
        """)
    }
}
