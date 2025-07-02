//
//  Actor.swift
//  NowPlayingClient
//
//  Created by Thanh Hai Khong on 15/5/25.
//

import NowPlayingClient
import AVKit

actor NowPlayingActor {
	
	private let nowPlaying = NowPlayingCenter()
	
	func initializeAudioSession(_ category: AVAudioSession.Category, _ mode: AVAudioSession.Mode, _ options: AVAudioSession.CategoryOptions) async throws {
		try await nowPlaying.initializeAudioSession(category, mode, options)
	}
	
	func setupRemoteCommands(_ handlers: NowPlayingClient.RemoteCommandHandlers) async {
		await nowPlaying.setupRemoteCommands(handlers)
	}

	func registerRemoteCommandEvents(_ enabledCommands: Set<NowPlayingClient.RemoteCommand>) -> AsyncStream<NowPlayingClient.RemoteCommandEvent> {
		nowPlaying.registerRemoteCommandEvents(enabledCommands)
	}
	
	func interruptionEvents() -> AsyncStream<NowPlayingClient.InterruptionEvent> {
		nowPlaying.interruptionEvents()
	}
	
	func updateStaticInfo(_ info: NowPlayingClient.StaticNowPlayingInfo) async throws {
		try await nowPlaying.updateStaticInfo(info)
	}
	
	func updateDynamicInfo(_ info: NowPlayingClient.DynamicNowPlayingInfo) async throws {
		try await nowPlaying.updateDynamicInfo(info)
	}
	
	func reset() async {
		await nowPlaying.reset()
	}
}
