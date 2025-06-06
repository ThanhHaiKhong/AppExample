//
//  PlayerStore.swift
//  Example
//
//  Created by Thanh Hai Khong on 26/4/25.
//

import ComposableArchitecture
import MediaPlayerClient
import AVFoundation
import TimerClient
import UIKit

public struct PlayableWitness: Sendable, Equatable, Hashable {
	public var id: String
	public var title: String
	public var artist: String
	public var thumbnailURL: URL?
	public var url: URL?
}

@Reducer
public struct PlayerStore {
    @ObservableState
    public struct State: Sendable {
        public var isPlaying: Bool = false
        public var isLoading: Bool = false
		public var isDragging: Bool = false
        
		public var shuffleMode: ShuffleMode = .off
        public var repeatMode: RepeatMode = .off
        public var speedMode: SpeedMode = .normal
        public var sleepMode: SleepMode = .off
		public var playbackEvent: MediaPlayerClient.PlaybackEvent = .idle
		public var playMode: MediaPlayerClient.PlayMode = .audioOnly
		
		public var currentTime: TimeInterval = .zero
		public var duration: TimeInterval = .zero
		
		internal var originalTracks: [PlayableWitness] = []
		internal var shuffles: [PlayableWitness] = []
		public var upnexts: [PlayableWitness] = []
		public var currentItem: PlayableWitness?
        
		public var sleepTimer = SleepTimer.State()
		public var equalizerStore = EqualizerStore.State()
		
        public init() {
            
        }
    }
    
    public enum Action: Equatable {
        case togglePlayPauseButtonTapped
        case nextButtonTapped
        case previousButtonTapped
        case shuffleButtonTapped
        case repeatButtonTapped
        case speedButtonTapped
        case timerButtonTapped
        case equalizerButtonTapped
        case moreButtonTapped
		case sliderTouchedUp(Float)
		case sliderTouchedDown
		case initializeMediaPlayer(UIView)
		case setTracks([PlayableWitness], Int)
		case currentItemChanged(PlayableWitness)
		case currentTimeChanged(TimeInterval)
		case durationChanged(TimeInterval)
		case playbackEventChanged(MediaPlayerClient.PlaybackEvent)
		case playModeChanged(MediaPlayerClient.PlayMode)
		case sleepTimer(SleepTimer.Action)
		case equalizerStore(EqualizerStore.Action)
		case speedModeChanged(State.SpeedMode)
    }
    
    @Dependency(\.mediaPlayerClient) var mediaPlayerClient
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
			case let .initializeMediaPlayer(containerView):
				return initializeMediaPlayer(containerView: containerView, state: &state)
				
			case .previousButtonTapped:
				return handlePreviousButtonTapped(state: &state)
				
			case .nextButtonTapped:
				return handleNextButtonTapped(state: &state)
				
			case .togglePlayPauseButtonTapped:
				return handleTogglePlayPauseButtonTapped(state: &state)
				
			case .shuffleButtonTapped:
				return handleShuffleButtonTapped(state: &state)
				
			case .repeatButtonTapped:
				return handleRepeatButtonTapped(state: &state)
				
			case .sliderTouchedDown:
				return handleSliderTouchedDown(state: &state)
				
			case let .sliderTouchedUp(value):
				return handleSliderTouchedUp(state: &state, value: value)
				
			case let .playModeChanged(playMode):
				state.playMode = playMode
				return .none
				
			case let .currentTimeChanged(currentTime):
				state.currentTime = currentTime
				return .none
				
			case let .durationChanged(duration):
				state.duration = duration
				return .none
				
			case let .speedModeChanged(speedMode):
				return handleSpeedModeChanged(state: &state, speedMode: speedMode)
				
			case let .playbackEventChanged(event):
				return handlePlaybackEventChanged(state: &state, event: event)
				
			case let .currentItemChanged(item):
				return handleCurrentItemChanged(state: &state, item: item)
				
			case let .setTracks(tracks, index):
				state.originalTracks = tracks
				state.upnexts = tracks.subarray(from: index + 1)
				return .run { send in
					await send(.currentItemChanged(tracks[index]))
				}
				
			case let .sleepTimer(action):
				return handleSleepTimerAction(state: &state, action: action)
				
			case let .equalizerStore(action):
				return handleEqualizerStoreAction(state: &state, action: action)
				
            default:
                return .none
            }
        }
		
		Scope(state: \.sleepTimer, action: \.sleepTimer) {
			SleepTimer()
		}
		
		Scope(state: \.equalizerStore, action: \.equalizerStore) {
			EqualizerStore()
		}
    }
    
    public init() { }
}

extension PlayerStore {
	
	private func initializeMediaPlayer(containerView: UIView, state: inout State) -> Effect<Action> {
		return .run { send in
			try await mediaPlayerClient.initialize(containerView, .video)
			try await mediaPlayerClient.setListEQ([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
		
			for await event in await mediaPlayerClient.events() {
				switch event {
				case .idle:
					print("PLAYBACK_EVENT: idle")
					await send(.playbackEventChanged(.idle))
					
				case .readyToPlay:
					print("PLAYBACK_EVENT: Ready to play")
					await send(.playbackEventChanged(.readyToPlay))
					
				case .didStartPlaying:
					print("PLAYBACK_EVENT: Playback started")
					await send(.playbackEventChanged(.didStartPlaying))
					
				case .didPause:
					print("PLAYBACK_EVENT: Playback paused")
					await send(.playbackEventChanged(.didPause))
					
				case .didStop:
					print("PLAYBACK_EVENT: Playback stopped")
					await send(.playbackEventChanged(.didStop))
					
				case .didFinish:
					print("PLAYBACK_EVENT: Playback finished")
					await send(.playbackEventChanged(.didFinish))
					
				case .didToEnd:
					print("PLAYBACK_EVENT: Playback reached end")
					await send(.playbackEventChanged(.didToEnd))
					
				case let .buffering(isBuffering):
					print("PLAYBACK_EVENT: Buffering: \(isBuffering)")
					await send(.playbackEventChanged(.buffering(isBuffering)))
					
				case let .error(error):
					print("🐞 PLAYBACK_EVENT: error \(error.localizedDescription)")
					await send(.playbackEventChanged(.error(error)))
				}
			}
		} catch: { error, send in
			
		}
	}
	
	private func handlePreviousButtonTapped(state: inout State) -> Effect<Action> {
		guard let currentItem = state.currentItem,
			  let currentIndex = state.shuffleMode == .on ?
				state.shuffles.firstIndex(of: currentItem) :
				state.originalTracks.firstIndex(of: currentItem) else {
			return .none
		}
		
		let previousIndex = currentIndex - 1
		
		guard previousIndex >= 0 else {
			return .none
		}
		
		let previousItem = state.shuffleMode == .on ?
			state.shuffles[previousIndex] :
			state.originalTracks[previousIndex]
		state.upnexts = state.shuffleMode == .on ?
			state.shuffles.subarray(from: previousIndex + 1) :
			state.originalTracks.subarray(from: previousIndex + 1)
		
		return .run { send in
			await send(.currentItemChanged(previousItem))
		}
	}
	
	private func handleNextButtonTapped(state: inout State) -> Effect<Action> {
		guard let currentItem = state.currentItem,
			  let currentIndex = state.shuffleMode == .on ?
				state.shuffles.firstIndex(of: currentItem) :
				state.originalTracks.firstIndex(of: currentItem) else {
			return .none
		}
		
		let nextIndex = currentIndex + 1
		
		if nextIndex < (state.shuffleMode == .on ? state.shuffles : state.originalTracks).count {
			let nextItem = state.shuffleMode == .on ?
			state.shuffles[nextIndex] :
			state.originalTracks[nextIndex]
			
			state.upnexts = state.shuffleMode == .on ?
			state.shuffles.subarray(from: nextIndex + 1) :
			state.originalTracks.subarray(from: nextIndex + 1)
			
			return .run { send in
				await send(.currentItemChanged(nextItem))
			}
		} else {
			if state.repeatMode == .all {
				let firstItem = state.shuffleMode == .on ?
				state.shuffles[0] :
				state.originalTracks[0]
				
				state.upnexts = state.shuffleMode == .on ?
				state.shuffles.subarray(from: 1) :
				state.originalTracks.subarray(from: 1)
				
				return .run { send in
					await send(.currentItemChanged(firstItem))
				}
			} else if state.repeatMode == .one {
				return handlePreviousButtonTapped(state: &state)
			} else {
				return .none
			}
		}
	}
	
	private func handleTogglePlayPauseButtonTapped(state: inout State) -> Effect<Action> {
		return .run { [isPlaying = state.isPlaying] send in
			if isPlaying {
				try await mediaPlayerClient.pause()
			} else {
				try await mediaPlayerClient.play()
			}
		} catch: { error, send in
			
		}
	}
	
	private func handleShuffleButtonTapped(state: inout State) -> Effect<Action> {
		switch state.shuffleMode {
		case .on:
			state.shuffleMode = .off
			if let currentItem = state.currentItem,
			   let currentIndex = state.originalTracks.firstIndex(of: currentItem) {
				state.upnexts = Array(state.originalTracks.dropFirst(currentIndex + 1))
			}
			
		case .off:
			state.shuffleMode = .on
			state.shuffles = state.originalTracks.shuffled()
			if let currentItem = state.currentItem,
			   let currentIndex = state.shuffles.firstIndex(of: currentItem) {
				state.upnexts = Array(state.shuffles.dropFirst(currentIndex + 1))
			}
		}
		return .none
	}
	
	private func handleRepeatButtonTapped(state: inout State) -> Effect<Action> {
		switch state.repeatMode {
		case .off:
			state.repeatMode = .one
			
		case .one:
			state.repeatMode = .all
			
		case .all:
			state.repeatMode = .off
		}
		return .none
	}
	
	private func handleSliderTouchedDown(state: inout State) -> Effect<Action> {
		state.isDragging = true
		return .none
	}
	
	private func handleSliderTouchedUp(state: inout State, value: Float) -> Effect<Action> {
		state.isDragging = false
		return .run { send in
			let time = TimeInterval(value)
			try await mediaPlayerClient.seek(time: time)
		} catch: { error, send in
			print("Error seeking: \(error.localizedDescription)")
		}
	}
	
	private func handleSliderValueChanged(state: inout State, value: Float) -> Effect<Action> {
		return .none
	}
	
	private func handleDidToEnd(state: inout State) -> Effect<Action> {
		resetPlaybackState(&state)
		
		if state.repeatMode == .one {
			return .run { send in
				try await mediaPlayerClient.seek(time: 0)
				try await mediaPlayerClient.play()
			} catch: { error, send in
				print("Error seeking to start: \(error.localizedDescription)")
			}
		} else {
			return handleNextButtonTapped(state: &state)
		}
	}
	
	private func handlePlaybackEventChanged(state: inout State, event: MediaPlayerClient.PlaybackEvent) -> Effect<Action> {
		state.playbackEvent = event
		if event == .didStartPlaying {
			state.isPlaying = true
			state.isLoading = false
		} else if event == .didPause {
			state.isPlaying = false
		} else if event == .didToEnd {
			return handleDidToEnd(state: &state)
		}
		return .none
	}
	
	private func handleCurrentItemChanged(state: inout State, item: PlayableWitness) -> Effect<Action> {
		state.currentItem = item
		state.isLoading = true
		
		return .run { [duration = state.duration] send in
			guard let url = item.url else {
				return
			}
			try await mediaPlayerClient.setTrack(url: url)
			
			for await timeRecord in await mediaPlayerClient.currentTime() {
				let currentTime = timeRecord.0
				let currentDuration = timeRecord.1
				if currentDuration != duration {
					await send(.durationChanged(currentDuration))
				}
				await send(.currentTimeChanged(currentTime))
			}
		} catch: { error, send in
			print("Error setting track: \(error.localizedDescription)")
		}
	}
	
	private func handleSleepTimerAction(state: inout State, action: SleepTimer.Action) -> Effect<Action> {
		switch action {	
		case .timerDidFinish:
			return .run { send in
				try await mediaPlayerClient.pause()
			} catch: { error, send in
				print("Error stopping playback: \(error.localizedDescription)")
			}
			
		default:
			return .none
		}
	}
	
	private func handleSpeedModeChanged(state: inout State, speedMode: State.SpeedMode) -> Effect<Action> {
		state.speedMode = speedMode
		return .run { send in
			try await mediaPlayerClient.setPlaybackRate(speedMode.rawValue)
		} catch: { error, send in
			print("Error setting playback rate: \(error.localizedDescription)")
		}
	}
	
	private func handleEqualizerStoreAction(state: inout State, action: EqualizerStore.Action) -> Effect<Action> {
		switch action {
			
		default:
			return .none
		}
	}
	
	private func resetPlaybackState(_ state: inout State) {
		state.isPlaying = false
		state.currentTime = .zero
		state.duration = .zero
	}
}

extension PlayerStore.State {
	
    public enum ShuffleMode: String, CaseIterable, Sendable, Equatable {
        case off
        case on
        
        public var tinColor: UIColor {
            switch self {
            case .off:
                return .blueBerry
            case .on:
                return .redPink
            }
        }
    }
    
    public enum RepeatMode: String, CaseIterable, Sendable, Equatable {
        case off
        case one
        case all
        
        public var tintColor: UIColor {
            switch self {
            case .off:
                return .blueBerry
            case .one:
                return .redPink
            case .all:
                return .redPink
            }
        }
    }
    
    public enum SpeedMode: Float, CaseIterable, Sendable, Equatable, Hashable {
        case verySlow
        case slow
        case normal
        case fast
        case veryFast
		
		public var title: String {
			switch self {
			case .verySlow:
				return "0.25x"
			case .slow:
				return "0.5x"
			case .normal:
				return "1.0x"
			case .fast:
				return "1.5x"
			case .veryFast:
				return "2.0x"
			}
		}
        
        public var description: String {
            switch self {
            case .verySlow:
                return "Very Slow"
            case .slow:
                return "Slow"
            case .normal:
                return "Normal"
            case .fast:
                return "Fast"
            case .veryFast:
                return "Very Fast"
            }
        }
        
        public var rawValue: Float {
            switch self {
            case .verySlow:
                return 0.25
            case .slow:
                return 0.5
            case .normal:
                return 1.0
            case .fast:
                return 1.5
            case .veryFast:
                return 2.0
            }
        }
        
        public var tintColor: UIColor {
            switch self {
            case .verySlow:
                return .systemTeal
            case .slow:
                return .systemGreen
            case .normal:
                return .systemBlue
            case .fast:
                return .systemOrange
            case .veryFast:
                return .systemRed
            }
        }
        
        public var imageNamed: String {
            switch self {
            case .verySlow:
                return "arrow.down.circle.fill"
            case .slow:
                return "arrow.down.right.circle.fill"
            case .normal:
                return "arrow.right.circle.fill"
            case .fast:
                return "arrow.up.right.circle.fill"
            case .veryFast:
                return "arrow.up.circle.fill"
            }
        }
    }
    
    public enum SleepMode: String, CaseIterable, Sendable, Equatable, Hashable {
        case off
        case fiveMinutes
        case tenMinutes
        case fifteenMinutes
        case thirtyMinutes
        case oneHour
        
        public var description: String {
            switch self {
            case .off:
                return "Off"
            case .fiveMinutes:
                return "5 Minutes"
            case .tenMinutes:
                return "10 Minutes"
            case .fifteenMinutes:
                return "15 Minutes"
            case .thirtyMinutes:
                return "30 Minutes"
            case .oneHour:
                return "1 Hour"
            }
        }
        
        public var duration: TimeInterval {
            switch self {
            case .off:
                return 0
            case .fiveMinutes:
                return 5 * 60
            case .tenMinutes:
                return 10 * 60
            case .fifteenMinutes:
                return 15 * 60
            case .thirtyMinutes:
                return 30 * 60
            case .oneHour:
                return 60 * 60
            }
        }
        
        public var tintColor: UIColor {
            switch self {
            case .off:
                return .systemGray
            case .fiveMinutes:
                return .systemGreen
            case .tenMinutes:
                return .systemBlue
            case .fifteenMinutes:
                return .systemYellow
            case .thirtyMinutes:
                return .systemOrange
            case .oneHour:
                return .systemRed
            }
        }
    }
}
