//
//  Engine.swift
//  WasmHost
//
//  Created by L7Studio on 26/12/24.
//
import Foundation
import SwiftProtobuf
import WasmKit

public protocol AsyncWasmProtocol {
    var url: URL { get }
    var premium: Bool { get set }
    // call extra options
    // key is module
    // value is serialized module options
    var copts: [String: Data] { get set }
    init(file: URL) throws
    func call(_ data: Data) async throws -> Data
    func version() async throws -> Data
}

extension AsyncifyCommand.Event {
    func to_error() -> Swift.Error? {
        switch data {
        case let .error(e):
            return NSError(domain: Constants.errorDomain,
                           code: Int(e.code),
                           userInfo: [NSLocalizedDescriptionKey: e.reason])
        default:
            return nil
        }
    }
}

public extension AsyncWasmProtocol {
    func grpc_call(_ cmd: AsyncifyCommand) async throws -> Data {
        try await call(cmd, contentType: "application/grpc")
    }
    
    func json_call(_ cmd: AsyncifyCommand) async throws -> Data {
        try await call(cmd, contentType: "application/json")
    }
    
    private func call(_ cmd: AsyncifyCommand, contentType: String) async throws -> Data {
        var cmd = cmd
        cmd.options.contentType = contentType
        cmd.options.premium = premium
        cmd.options.extra = Google_Protobuf_Struct(fields: [:])
        for (k, v) in copts {
            if let val = String(data: v, encoding: .utf8) {
                cmd.options.extra[k] = Google_Protobuf_Value(stringValue: val)
            }
        }
        return try await call(cmd.serializedData())
    }
    
    func cast<T>(_ data: Data) async throws -> T where T: SwiftProtobuf.Message {
        do {
            return try T(serializedBytes: data)
        } catch {
            throw try AsyncifyCommand.Event(serializedBytes: data).to_error() ?? error
        }
    }
    
    func cast<T>(_ data: Data) async throws -> T where T: Decodable {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw try AsyncifyCommand.Event(serializedBytes: data).to_error() ?? error
        }
    }
    
    func call<T>(_ cmd: AsyncifyCommand) async throws -> T where T: SwiftProtobuf.Message {
        try await cast(await grpc_call(cmd))
    }
    
    func call<T>(_ cmd: AsyncifyCommand) async throws -> T where T: Decodable {
        try await cast(await json_call(cmd))
    }
}

class AsyncWasmInstance: NSObject {
    let _wasm: _AsyncWasm
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
        _wasm = try _AsyncWasm(path: file.path)
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
}

public extension AsyncWasmProtocol {
    func version() async throws -> EngineVersion {
        var ret: EngineVersion = try await cast(await version())
        ret.url = url.absoluteString
        return ret
    }
}

@objc
open class AsyncWasmEngine: NSObject, AsyncWasmProtocol {
    @objc
    public let url: URL
    @objc
    public var premium: Bool = false {
        didSet {
            if _wasm != nil {
                _wasm.premium = premium
            }
        }
    }
    @objc
    public var copts: [String : Data] = [:] {
        didSet {
            if _wasm != nil {
                _wasm.copts = copts
            }
        }
    }
    
    lazy var wasmer: () async throws -> AsyncWasmInstance = {
        defer { WALogger.host.debug("loaded engine at \(self.url)") }
        return try AsyncWasmInstance(file: self.url) { [weak self] in
            let caller = try AsyncifyCommand.Call(id: EngineCallID.initialize)
            return try await self?.grpc_call(AsyncifyCommand(call: caller)) ?? Data()
        }
    }
    private var _wasm: AsyncWasmInstance!
    
    @objc
    public required init(file: URL) throws {
        self.url = file
        super.init()
    }
    
    private func reinit() async throws {
        await self._wasm?.release()
        self._wasm = try await wasmer()
        self._wasm.premium = premium
        self._wasm.copts = copts
    }
    func wasm() async throws -> AsyncWasmInstance {
        if (_wasm == nil) {
            try await self.reinit()
        }
        return _wasm
    }
    @objc(callWithData:completionHandler:)
    public func call(_ data: Data) async throws -> Data {
        try await self.tryRun {
            try await wasm().call(data)
        }
    }
    @objc(setCallOptions:completionHandler:)
    public func set(copts: [String: Data]) async throws {
        try await self.wasm().copts = copts
    }
    
    func tryRun<R>(body: () async throws -> R) async rethrows -> R {
        do {
            return try await body()
        } catch {
            if error is WasmKit.Trap {
                try await self.reinit()
            }
            throw error
        }
    }
    @objc(versionWithCompletionHandler:)
    public func version() async throws -> Data {
        let caller = try AsyncifyCommand.Call(id: EngineCallID.getVersion)
        return try await grpc_call(AsyncifyCommand(call: caller))
    }
    
}
