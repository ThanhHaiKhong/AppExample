//
//  instance.swift
//  WasmHost
//
//  Created by L7Studio on 27/2/25.
//
import Foundation

protocol WasmInstance: AnyObject {
    var url: URL { get }
    var premium: Bool { get set }
    var copts: [String: Data] { get set }
    func call(_ data: Data) async throws -> Data
    func release() async
    func rebuildWhen(error: Swift.Error) -> Bool
}

#if canImport(AsyncWasmKit)
import AsyncWasmKit
import WasmKit
class DefaultWasmInstance: NSObject, WasmInstance {
    let _wasm: AsyncWasmKit.AsyncifyWasm
    var _initialized = false
    
    public let url: URL
    @objc
    public var premium: Bool = false
    @objc
    public var copts: [String: Data] = [:]
    let initialize: () async throws -> Data
    required init(file: URL, initialize: @escaping () async throws -> Data) throws {
        self.initialize = initialize
        url = file
        _wasm = try AsyncWasmKit.AsyncifyWasm(path: file.path)
    }
    
    func call(_ data: Data) async throws -> Data {
        if !_initialized {
            _initialized = true
            _ = try await self.initialize()
        }
        return try await _wasm.call(data)
    }
    func release() async {
        await _wasm.release()
    }
    func rebuildWhen(error: any Error) -> Bool {
        error is WasmKit.Trap
    }
}
#endif
#if canImport(asyncify_wasmFFI)
import MobileFFI
class DefaultWasmInstance: NSObject, WasmInstance {
    let _wasm: AsyncifyWasm
    var _initialized = false
    
    public let url: URL
    @objc
    public var premium: Bool = false
    @objc
    public var copts: [String: Data] = [:]
    let initialize: () async throws -> Data
    required init(file: URL, initialize: @escaping () async throws -> Data) async throws {
        self.initialize = initialize
        url = file
        var opts: Options? = nil
#if DEBUG
        let wopts = WasmOptions.wasmtime(target: "pulley64",
                                         memoryReversation: 4 << 30,
                                         memoryReversationForGrowth: 2 << 30,
                                         storeMemorySize: nil
        )
        opts = Options(wasm: wopts)
//        mffiLogWithMaxLevel(level: "info")
#endif 
        _wasm = try await AsyncifyWasm(path: file.path, opts: opts)
        try await _wasm.start()
    }
    
    func call(_ data: Data) async throws -> Data {
        if !_initialized {
            _initialized = true
            _ = try await self.initialize()
        }
        return try await _wasm.call(cmd: data)
    }
    func release() async {
    }
    func rebuildWhen(error: any Error) -> Bool {
        error is AsyncifyWasmError
    }
}
#endif
