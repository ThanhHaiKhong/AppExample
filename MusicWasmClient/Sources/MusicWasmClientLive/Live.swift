//
//  Live.swift
//  MusicWasmClient
//
//  Created by Thanh Hai Khong on 8/5/25.
//

import ComposableArchitecture
import MusicWasmClient

extension MusicWasmClient: DependencyKey {
	public static let liveValue: MusicWasmClient = {
		let actor = MusicWasmActor()
		
		return MusicWasmClient(
			initialize: { engine in
				await actor.initialize(engine)
			},
			engineState: {
				await actor.engineState()
			},
			engineStateStream: {
				await actor.engineStateStream()
			},
			details: { vid in
				try await actor.details(vid: vid)
			},
			suggestion: { keyword in
				try await actor.suggestion(keyword: keyword)
			},
			search: { keyword, scope, continuation in
				try await actor.search(keyword: keyword, scope: scope, continuation: continuation)
			},
			tracks: { pid, continuation in
				try await actor.tracks(pid: pid, continuation: continuation)
			},
			discover: { category, continuation in
				try await actor.discover(category: category, continuation: continuation)
			},
		)
	}()
}

