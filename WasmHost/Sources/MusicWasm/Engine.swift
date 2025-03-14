//
//  Engine.swift
//  WasmHost
//
//  Created by L7Studio on 17/1/25.
//
import AsyncWasm
import Foundation
import SwiftProtobuf
import WasmSwiftProtobuf

extension MusicCallID: CallerID {}

public protocol MusicWasmProtocol: AsyncWasmProtocol {
    func details(vid: String) async throws -> MusicTrackDetails
    func suggestion(keyword: String) async throws -> MusicListSuggestions
    func search(keyword: String, scope: String, continuation: String?) async throws -> MusicListTracks
    func tracks(pid: String, continuation: String?) async throws -> MusicListTracks
    func options() async throws -> MusicListOptions
    func discover(category: String, continuation: String?) async throws -> MusicListTracks
}

public func music() async throws -> MusicWasmProtocol {
    MusicWasmEngine()
}

public extension MusicWasmEngine {
    internal static let kMaxRetryCount = 10

    func details(vid: String) async throws -> MusicTrackDetails {
        var attempts = 0

        while attempts < Self.kMaxRetryCount {
            attempts += 1
            let val: MusicTrackDetails = try await cast(await details(vid: vid))
            if val.formats.isEmpty {
                WALogger.host.debug("[\(vid)] \(attempts) retrying...")
                try await Task.sleep(nanoseconds: UInt64(backoff(attempts: attempts) * 1_000_000_000))
                continue
            }
            if let url = val.formats.first?.url, let url = URL(string: url) {
                var req = URLRequest(url: url)
                req.httpMethod = "HEAD"
                let resp = try await URLSession.shared.data(for: req)
                let status = (resp.1 as? HTTPURLResponse)?.statusCode ?? -1
                if status == 200 {
                    return val
                }
            }
        }
        throw Constants.Error.maximumRetryExceededError.error()
    }

    func transcript(vid: String) async throws -> MusicTranscript {
        try await cast(await transcript(vid: vid))
    }

    func discover(category: String, continuation: String?) async throws -> MusicListTracks {
        try await cast(await discover(category: category, continuation: continuation))
    }

    func options() async throws -> MusicListOptions {
        try await cast(await options())
    }

    func suggestion(keyword: String) async throws -> MusicListSuggestions {
        try await cast(await suggestion(keyword: keyword))
    }

    func search(keyword: String, scope: String, continuation: String?) async throws -> MusicListTracks {
        try await cast(await search(keyword: keyword, scope: scope, continuation: continuation))
    }

    func tracks(pid: String, continuation: String?) async throws -> MusicListTracks {
        try await cast(await tracks(pid: pid, continuation: continuation))
    }
}

@objc
public class MusicWasmEngine: AsyncWasmEngine, MusicWasmProtocol {

    @objc(detailsWithVideoId:completionHandler:)
    public func details(vid: String) async throws -> Data {
        let args = [
            "url": Google_Protobuf_Value(stringValue: vid),
        ]
        let caller = try AsyncifyCommand.Call(id: MusicCallID.getDetails, args: args)
        return try await grpc_call(AsyncifyCommand(call: caller))
    }

    @objc(transcriptWithVideoId:completionHandler:)
    public func transcript(vid: String) async throws -> Data {
        let args = [
            "vid": Google_Protobuf_Value(stringValue: vid),
        ]
        let caller = try AsyncifyCommand.Call(id: MusicCallID.getTranscript, args: args)
        return try await grpc_call(AsyncifyCommand(call: caller))
    }

    @objc(getDiscoverWithCategory:continuation:completionHandler:)
    public func discover(category: String, continuation: String?) async throws -> Data {
        var args = [
            "category": Google_Protobuf_Value(stringValue: category),
        ]
        if let continuation, !continuation.isEmpty {
            args["continuation"] = Google_Protobuf_Value(stringValue: continuation)
        }
        let caller = try AsyncifyCommand.Call(id: MusicCallID.getDiscover, args: args)
        return try await grpc_call(AsyncifyCommand(call: caller))
    }

    @objc(optionsWithCompletionHandler:)
    public func options() async throws -> Data {
        let caller = try AsyncifyCommand.Call(id: MusicCallID.getOptions)
        return try await grpc_call(AsyncifyCommand(call: caller))
    }

    @objc(suggestionWithKeyword:completionHandler:)
    public func suggestion(keyword: String) async throws -> Data {
        let args = [
            "keyword": Google_Protobuf_Value(stringValue: keyword),
        ]
        let caller = try AsyncifyCommand.Call(
            id: MusicCallID.suggestion,
            args: args
        )
        return try await grpc_call(AsyncifyCommand(call: caller))
    }

    @objc(searchWithKeyword:scope:continuation:completionHandler:)
    public func search(keyword: String, scope: String, continuation: String?) async throws -> Data {
        var args = [
            "keyword": Google_Protobuf_Value(stringValue: keyword),
            "scope": Google_Protobuf_Value(stringValue: scope),
        ]
        if let continuation, !continuation.isEmpty {
            args["continuation"] = Google_Protobuf_Value(stringValue: continuation)
        }
        let caller = try AsyncifyCommand.Call(
            id: MusicCallID.search,
            args: args
        )
        return try await grpc_call(AsyncifyCommand(call: caller))
    }

    @objc(trackWithPlaylistId:continuation:completionHandler:)
    public func tracks(pid: String, continuation: String?) async throws -> Data {
        var args = [
            "id": Google_Protobuf_Value(stringValue: pid),
        ]
        if let continuation {
            args["continuation"] = Google_Protobuf_Value(stringValue: continuation)
        }
        let caller = try AsyncifyCommand.Call(
            id: MusicCallID.getPlaylistDetails,
            args: args
        )
        return try await grpc_call(AsyncifyCommand(call: caller))
    }
}
