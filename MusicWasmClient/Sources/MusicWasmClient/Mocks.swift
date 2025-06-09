//
//  Mocks.swift
//  MusicWasmClient
//
//  Created by Thanh Hai Khong on 8/5/25.
//

import Dependencies
import WasmSwiftProtobuf
import MusicWasm

extension DependencyValues {
	public var musicWasmClient: MusicWasmClient {
		get { self[MusicWasmClient.self] }
		set { self[MusicWasmClient.self] = newValue }
	}
}

extension MusicWasmClient: TestDependencyKey {
	
	public static let testValue = MusicWasmClient(
		initialize: { engine in
			
		},
		engineState: {
			.loaded
		},
		engineStateStream: {
			AsyncStream { continuation in
				continuation.yield(.idle)
				continuation.yield(.loading)
				continuation.yield(.loaded)
				continuation.finish()
			}
		},
		details: { _ in
			MusicTrackDetails()
		},
		suggestion: { _ in
			MusicListSuggestions()
		},
		search: { _, _, _ in
			MusicListTracks()
		},
		tracks: { _, _ in
			MusicListTracks()
		},
		discover: { _, _ in
			MusicListTracks()
		},
		transcript: { _ in
			MusicTranscript()
		},
	)
	
	public static let previewValue = MusicWasmClient()
}
