// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import WasmSwiftProtobuf
import MusicWasm

@DependencyClient
public struct MusicWasmClient: Sendable {
	public var initialize: @Sendable (_ engine: MusicWasmEngine) async -> Void
	public var engineState: @Sendable () async throws -> MusicWasmClient.EngineState = {
		return .idle
	}
	public var engineStateStream: @Sendable () async -> AsyncStream<EngineState> = {
		AsyncStream { _ in
			
		}
	}
	public var details: @Sendable(_ vid: String) async throws -> MusicTrackDetails = { _ in
		MusicTrackDetails()
	}
	public var suggestion: @Sendable(_ keyword: String) async throws -> MusicListSuggestions = { _ in
		MusicListSuggestions()
	}
	public var search: @Sendable(_ keyword: String, _ scope: MusicSearchScope, _ continuation: String?) async throws -> MusicListTracks = { _, _, _ in
		MusicListTracks()
	}
	public var tracks: @Sendable(_ pid: String, _ continuation: String?) async throws -> MusicListTracks = { _, _ in
		MusicListTracks()
	}
	public var discover: @Sendable(_ category: MusicDiscoverCategory, _ continuation: String?) async throws -> MusicListTracks = { _, _ in
		MusicListTracks()
	}
}
