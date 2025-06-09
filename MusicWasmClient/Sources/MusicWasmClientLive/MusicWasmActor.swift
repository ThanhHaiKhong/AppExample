//
//  MusicWasmActor.swift
//  MusicWasmClient
//
//  Created by Thanh Hai Khong on 8/5/25.
//

@preconcurrency import MusicWasm
import MusicWasmClient
import WasmSwiftProtobuf
import AsyncWasm
import TaskWasm

enum MusicWasmError: Error {
	case engineNotReady(MusicWasmClient.EngineState)
}

actor MusicWasmActor {
	
	private var engine: MusicWasmProtocol?
	private var state: MusicWasmClient.EngineState = .idle
	private var loadError: Error?
	
	init() {
		Task {
			await ensureEngineLoaded()
		}
	}
}

// MARK: - Public Methods

extension MusicWasmActor {
	
	func initialize(_ engine: MusicWasmEngine) async {
		if state == .loaded {
			return
		}
		self.engine = engine
		state = .loaded
	}
	
	func engineStateStream() -> AsyncStream<MusicWasmClient.EngineState> {
		return AsyncStream { continuation in
			Task {
				var lastState = engineState()
				continuation.yield(lastState)
				while !Task.isCancelled {
					try await Task.sleep(nanoseconds: 100_000_000) // Poll every 100ms
					let currentState = engineState()
					if currentState != lastState {
						continuation.yield(currentState)
						lastState = currentState
					}
				}
				continuation.finish()
			}
		}
	}
	
	func engineState() -> MusicWasmClient.EngineState {
		state
	}
	
	func lastError() -> Error? {
		loadError
	}
	
	func discover(category: MusicDiscoverCategory, continuation: String?) async throws -> MusicListTracks {
		try await withEngine { engine in
			try await engine.discover(category: category, continuation: continuation)
		}
	}
	
	func tracks(pid: String, continuation: String?) async throws -> MusicListTracks {
		try await withEngine { engine in
			try await engine.tracks(pid: pid, continuation: continuation)
		}
	}
	
	func details(vid: String) async throws -> MusicTrackDetails {
		try await withEngine { engine in
			try await engine.details(vid: vid)
		}
	}
	
	func suggestion(keyword: String) async throws -> MusicListSuggestions {
		try await withEngine { engine in
			try await engine.suggestion(keyword: keyword)
		}
	}
	
	func search(keyword: String, scope: MusicSearchScope = .all, continuation: String?) async throws -> MusicListTracks {
		try await withEngine { engine in
			try await engine.search(keyword: keyword, scope: scope, continuation: continuation)
		}
	}
	
	func transcript(vid: String) async throws -> MusicTranscript {
		try await withEngine { engine in
			if let engine = engine as? MusicWasmEngine {
				return try await engine.transcript(vid: vid)
			} else {
				return MusicTranscript()
			}
		}
	}
}

// MARK: - Private Methods

extension MusicWasmActor {
	
	private func ensureEngineLoaded() async -> MusicWasmClient.EngineState {
		if engine != nil {
			return .loaded
		}
		
		state = .loading
		do {
			let engine = try await MusicWasm.default()
			try await engine.start()
			self.engine = engine
			state = .loaded
			loadError = nil
			return .loaded
		} catch {
			state = .error(error)
			loadError = error
			return state
		}
	}
	
	private func withEngine<T: Sendable>(_ action: (MusicWasmProtocol) async throws -> T) async throws -> T {
		let state = await ensureEngineLoaded()
		guard state == .loaded, let engine = engine else {
			throw MusicWasmError.engineNotReady(state)
		}
		return try await action(engine)
	}
}

extension MusicWasmEngine: @unchecked @retroactive Sendable {
	
}

extension MusicWasm.MusicSearchScope: @unchecked @retroactive Sendable {
	
}

extension MusicWasm.MusicDiscoverCategory: @unchecked @retroactive Sendable {
	
}

extension WasmSwiftProtobuf.MusicTranscript {
	public var fullTranscript: String {
		return segments.map { $0.text }.joined(separator: " ")
	}
}
