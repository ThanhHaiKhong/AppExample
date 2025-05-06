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
		case setEnabled(Bool)
		case setEqualizer(Float, Int)
		case initializeMediaPlayer(UIView)
	}
	
	@Dependency(\.mediaPlayerClient) var mediaPlayerClient
	
	public var body: some Reducer<State, Action> {
		Reduce { state, action in
			switch action {
			case .onDidLoad:
				return .run { send in
					let isEnabled = await mediaPlayerClient.isEqualizerEnabled()
					await send(.setEnabled(isEnabled))
				} catch: { error, send in
					print("Error loading equalizer: \(error.localizedDescription)")
				}
				
			case let .setEnabled(isEnabled):
				state.isEnabled = isEnabled
				return .run { send in
					try await mediaPlayerClient.setEnableEqualizer(enabled: isEnabled)
					if isEnabled {
						let listEQ: [Float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
						try await mediaPlayerClient.setListEQ(listEQ: listEQ)
					}
				} catch: { error, send in
					print("Error setting equalizer: \(error.localizedDescription)")
				}
				
			case let .setEqualizer(value, index):
				return .run { send in
					try await mediaPlayerClient.setEqualizer(value, index)
				} catch: { error, send in
					print("Error setting equalizer: \(error.localizedDescription)")
				}
				
			case let .initializeMediaPlayer(containerView):
				guard let url = Bundle.main.url(forResource: "sample_track_4", withExtension: "mp4") else {
					return .none
				}
				
				return .run { send in
					try await mediaPlayerClient.initialize(containerView, .video)
					try await mediaPlayerClient.setListEQ([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
					try await mediaPlayerClient.setTrack(url: url)
				} catch: { error, send in
					print("Error initializing media player: \(error.localizedDescription)")
				}
			}
		}
	}
	
	public init() { }
}
