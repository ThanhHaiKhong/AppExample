//
//  EqualizerStore.swift
//  Example
//
//  Created by Thanh Hai Khong on 1/5/25.
//

import ComposableArchitecture
import MediaPlayerClient
import Foundation
import UIKit

@Reducer
public struct EqualizerStore: Sendable {
	@ObservableState
	public struct State: Sendable {
		public var isEnabled: Bool = false
		
		public init() {}
	}
	
	public enum Action: Sendable, Equatable {
		case onDidLoad
		case isEnabled(Bool)
		case setEnabled(Bool, [Float])
		case setEqualizer(Float, Int)
		case setEqualizerWith(MediaPlayerClient.AudioEqualizer.Preset)
		case initializeMediaPlayer(UIView)
	}
	
	@Dependency(\.mediaPlayerClient) var mediaPlayerClient
	
	public var body: some Reducer<State, Action> {
		Reduce { state, action in
			switch action {
			case .onDidLoad:
				return .run { send in
					let isEnabled = await mediaPlayerClient.isEqualizerEnabled()
					await send(.isEnabled(isEnabled))
				}
				
			case let .isEnabled(isEnabled):
				state.isEnabled = isEnabled
				return .none
				
			case let .setEnabled(isEnabled, listEQ):
				state.isEnabled = isEnabled
				return .run { send in
					try await mediaPlayerClient.setEnableEqualizer(isEnabled, listEQ)
				} catch: { error, send in
					print("Error setting equalizer: \(error.localizedDescription)")
				}
				
			case let .setEqualizer(value, index):
				return .run { send in
					try await mediaPlayerClient.setEqualizer(value, index)
				} catch: { error, send in
					print("Error setting equalizer: \(error.localizedDescription)")
				}
				
			case let .setEqualizerWith(preset):
				return .run { send in
					try await mediaPlayerClient.setEqualizerWith(preset)
				} catch: { error, send in
					print("Error setting equalizer: \(error.localizedDescription)")
				}
				
			case let .initializeMediaPlayer(containerView):
				guard let url = Bundle.main.url(forResource: "sample_track_4", withExtension: "mp4") else {
					return .none
				}
				
				return .run { send in
					await mediaPlayerClient.initialize(containerView, .video)
					try await mediaPlayerClient.setTrack(url: url)
				} catch: { error, send in
					print("Error initializing media player: \(error.localizedDescription)")
				}
			}
		}
	}
	
	public init() { }
}
