//
//  Engine.swift
//  WasmHost
//
//  Created by L7Studio on 26/12/24.
//
import Foundation
import SwiftProtobuf
import WasmSwiftProtobuf

public protocol AsyncWasmProtocol {
    var url: URL? { get }
    var premium: Bool { get set }
    // call extra options
    // key is module
    // value is serialized module options
    var copts: [String: Data] { get set }
    var delegate: WasmInstanceDelegate? { get set }
    init()
    init(file: URL?) throws
    func start() async throws
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

public extension AsyncWasmProtocol {
    func version() async throws -> EngineVersion {
        return try await cast(await version())
    }
}
@objc
open class AsyncWasmEngine: NSObject, AsyncWasmProtocol {
    @objc
    public var url: URL?
    @objc
    public var premium: Bool = false
    @objc
    public var copts: [String : Data] = [:]
    public weak var delegate: WasmInstanceDelegate?
    internal var _wasm: WasmInstance?
    @objc
    public override required init() {
        super.init()
    }
    @objc
    public required init(file: URL?) throws {
        self.url = file
        super.init()
    }
    func tryRun<R>(body: () async throws -> R) async rethrows -> R {
        do {
            return try await body()
        } catch {
            throw error
        }
    }
    @objc(versionWithCompletionHandler:)
    public func version() async throws -> Data {
        let caller = try AsyncifyCommand.Call(id: EngineCallID.getVersion)
        return try await grpc_call(AsyncifyCommand(call: caller))
    }
    @objc(callWithData:completionHandler:)
    public func call(_ data: Data) async throws -> Data {
        try await self.tryRun {
            try await _wasm?.call(cmd: data) ?? Data()
        }
    }
    @objc(setCallOptions:completionHandler:)
    public func set(copts: [String: Data]) async throws {
        self.copts = copts
    }
    
}

