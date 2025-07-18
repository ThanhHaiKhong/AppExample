//
//  Live.swift
//  NowPlayingClient
//
//  Created by Thanh Hai Khong on 14/5/25.
//

import Dependencies
import NowPlayingClient

extension NowPlayingClient: DependencyKey {
	public static let liveValue: NowPlayingClient = {
		let actor = NowPlayingActor()
		
		return NowPlayingClient(
			initializeAudioSession: { category, mode, options in
				try await actor.initializeAudioSession(category, mode, options)
			},
			registerRemoteCommandEvents: { enabledCommands in
				await actor.registerRemoteCommandEvents(enabledCommands)
			},
			interruptionEvents: {
				await actor.interruptionEvents()
			},
			updateStaticInfo: { info in
				try await actor.updateStaticInfo(info)
			},
			updateDynamicInfo: { info in
				try await actor.updateDynamicInfo(info)
			}
		)
	}()
}
