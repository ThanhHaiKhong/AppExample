//
//  MediaPlayerStore.swift
//  Example
//
//  Created by Thanh Hai Khong on 7/5/25.
//

import ComposableArchitecture
import MediaPlayerClient
import NowPlayingClient
import MusicWasmClient
import AVFoundation
import TimerClient
import UIKit
import Kingfisher

@Reducer
public struct MediaPlayerStore {
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
		public var thumbnailImage: UIImage?
		
		internal var originalTracks: [PlayableWitness] = []
		internal var shuffles: [PlayableWitness] = []
		internal var handlers = NowPlayingClient.RemoteCommandHandlers()
		
		public var upnexts: [PlayableWitness] = []
		public var currentItem: PlayableWitness?
		
		public var sleepTimer = SleepTimer.State()
		public var equalizerStore = EqualizerStore.State()
		
		public init() {
			handlers = handlers
				.withHandler(.nextTrack, .action {
					print("Next track")
					return .success
				})
				.withHandler(.togglePlayPause, .action {
					print("Toggle play/pause")
					return .success
				})
				.withHandler(.previousTrack, .action {
					return .success
				})
		}
	}
	
	public enum Action: Equatable {
		case dismissButtonTapped
		case togglePlayPauseButtonTapped
		case nextButtonTapped
		case previousButtonTapped
		case shuffleButtonTapped
		case repeatButtonTapped
		case speedButtonTapped
		case timerButtonTapped
		case equalizerButtonTapped
		case favoriteButtonTapped
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
		case didReorderTracks([PlayableWitness])
		case initializeNowPlaying
		case retrievedThumbnail(UIImage)
		case remoteCommandEventChanged(NowPlayingClient.RemoteCommandEvent)
	}
	
	@Dependency(\.mediaPlayerClient) var mediaPlayerClient
	@Dependency(\.musicWasmClient) var musicWasmClient
	@Dependency(\.nowPlayingClient) var nowPlayingClient
	
	public var body: some Reducer<State, Action> {
		Reduce { state, action in
			switch action {
			case .initializeNowPlaying:
				return .run { send in
					try await nowPlayingClient.initializeAudioSession(category: .playback, mode: .default, options: [])
					
					let enabledCommands: Set<NowPlayingClient.RemoteCommand> = [
						.changePlaybackPosition,
						.previousTrack,
						.togglePlayPause,
						.nextTrack,
					]
					
					for await event in await nowPlayingClient.remoteCommandEvents(enabledCommands) {
						await send(.remoteCommandEventChanged(event))
					}
				} catch: { error, send in
					print("🤪 Error initializing NowPlaying: \(error.localizedDescription)")
				}
				
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
				
			case .dismissButtonTapped:
				return handleDismissButtonTapped(state: &state)
				
			case .sliderTouchedDown:
				return handleSliderTouchedDown(state: &state)
				
			case .favoriteButtonTapped:
				return .none
				
			case let .sliderTouchedUp(value):
				return handleSliderTouchedUp(state: &state, value: value)
				
			case let .remoteCommandEventChanged(event):
				return handleRemoteCommandEventChanged(state: &state, event: event)
				
			case let .retrievedThumbnail(thumbnail):
				state.thumbnailImage = thumbnail
				return .run { [item = state.currentItem, duration = state.duration] send in
					var staticInfo = NowPlayingClient.StaticNowPlayingInfo()
					staticInfo.title = item?.title
					staticInfo.artist = item?.artist
					staticInfo.artwork = thumbnail
					staticInfo.duration = duration
					staticInfo.mediaType = .audio
					try await nowPlayingClient.updateStaticInfo(info: staticInfo)
				} catch: { error, send in
					print("Error updating static info: \(error.localizedDescription)")
				}
				
			case let .playModeChanged(playMode):
				state.playMode = playMode
				return .none
				
			case let .currentTimeChanged(currentTime):
				state.currentTime = currentTime
				return .run { [rate = state.speedMode.rawValue] send in
					let dynamicInfo = NowPlayingClient.DynamicNowPlayingInfo(elapsedTime: currentTime, playbackRate: rate)
					try await nowPlayingClient.updateDynamicInfo(dynamicInfo)
				} catch: { error, send in
					print("Error updating dynamic info: \(error.localizedDescription)")
				}
				
			case let .durationChanged(duration):
				state.duration = duration
				return .run { [item = state.currentItem, playMode = state.playMode, artwork = state.thumbnailImage] send in
					var staticInfo = NowPlayingClient.StaticNowPlayingInfo()
					staticInfo.title = item?.title
					staticInfo.artist = item?.artist
					staticInfo.artwork = artwork
					staticInfo.duration = duration
					staticInfo.mediaType = playMode == .audioOnly ? .audio : .video
					
					try await nowPlayingClient.updateStaticInfo(info: staticInfo)
					
					for await timeRecord in await mediaPlayerClient.currentTime() {
						let currentTime = timeRecord.0
						await send(.currentTimeChanged(currentTime))
					}
				}
				
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
				
			case let .didReorderTracks(tracks):
				state.upnexts = tracks
				return .none
				
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

extension MediaPlayerStore {
	
	private func initializeMediaPlayer(containerView: UIView, state: inout State) -> Effect<Action> {
		return .run { [playMode = state.playMode] send in
			await mediaPlayerClient.initialize(containerView, playMode)
			
			for await event in await mediaPlayerClient.events() {
				await send(.playbackEventChanged(event))
			}
		}
	}
	
	private func handlePreviousButtonTapped(state: inout State) -> Effect<Action> {
		guard let currentItem = state.currentItem,
			  let currentIndex = state.shuffleMode == .on ?
				state.shuffles.firstIndex(of: currentItem) :
				state.originalTracks.firstIndex(of: currentItem)
		else {
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
		print("🎶 MEDIA_PLAYER playback event changed: \(event)")
		switch event {
		case .idle:
			return .none
			
		case .readyToPlay:
			return .run { send in
				let duration = try await mediaPlayerClient.duration()
				await send(.durationChanged(duration))
			} catch: { error, send in
				print("Error getting duration: \(error.localizedDescription)")
			}
			
		case .didStartPlaying:
			state.isPlaying = true
			state.isLoading = false
			return .none
			
		case .didPause:
			state.isPlaying = false
			return .none
			
		case .didStop:
			state.isPlaying = false
			return .none
			
		case .didFinish:
			return .none
			
		case .didToEnd:
			return handleDidToEnd(state: &state)
			
		case .buffering:
			return .none
			
		case .error:
			return .none
		}
	}
	
	private func handleCurrentItemChanged(state: inout State, item: PlayableWitness) -> Effect<Action> {
		state.currentItem = item
		state.isLoading = true
		state.currentTime = .zero
		state.duration = .zero
		
		return .run { send in
			if let url = item.url {
				try await mediaPlayerClient.setTrack(url: url)
			} else {
				let details = try await musicWasmClient.details(vid: item.id)
				print("GET_DETAILS: \(details)")
				
				if let urlString = details.formats.filter({ $0.mimeType.contains("audio")}).first?.url,
				   let url = URL(string: urlString) {
					try await mediaPlayerClient.setTrack(url: url)
				}
			}
			
			if let thumbnailURL = item.thumbnailURL {
				let processor = ResizingImageProcessor(referenceSize: CGSize(width: 100, height: 100), mode: .aspectFill)
				let result = try await KingfisherManager.shared.retrieveImage(with: thumbnailURL, options: [.processor(processor)])
				await send(.retrievedThumbnail(result.image))
			}
			
			for await event in await nowPlayingClient.interruptionEvents() {
				switch event {
				case .began:
					print("Interruption began")
					try await mediaPlayerClient.pause()
					
				case let .ended(shouldResume):
					print("Interruption ended: \(shouldResume)")
					if shouldResume {
						try await mediaPlayerClient.play()
					}
				}
			}
		} catch: { error, send in
			print("🐛 ERROR_GET_DETAILS: \(error.localizedDescription)")
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
	
	private func handleDismissButtonTapped(state: inout State) -> Effect<Action> {
		return .run { send in
			for await state in await musicWasmClient.engineStateStream() {
				switch state {
				case .idle:
					print("Engine state: idle")
					
				case .loading:
					print("Engine state: loading")
					
				case .loaded:
					print("Engine state: loaded")
					let trendingList = try await musicWasmClient.discover(category: .trending, continuation: nil)
					print("Trending List: \(trendingList.items.count)")
					let playableWitnesses = trendingList.items.map { item in
						PlayableWitness(id: item.id, title: item.title, artist: item.author.name, thumbnailURL: URL(string: item.thumbnail))
					}
					
					await send(.setTracks(playableWitnesses, 0))
					
				case let .error(error):
					print("Engine state: error \(error.localizedDescription)")
				}
			}
		} catch: { error, send in
			print("Music Wasm Client Error: \(error.localizedDescription)")
		}
	}
	
	private func handleRemoteCommandEventChanged(state: inout State, event: NowPlayingClient.RemoteCommandEvent) -> Effect<Action> {
		switch event {
		case .previousTrack:
			return handlePreviousButtonTapped(state: &state)
			
		case .togglePlayPause:
			return handleTogglePlayPauseButtonTapped(state: &state)
			
		case .nextTrack:
			return handleNextButtonTapped(state: &state)
			
		case let .changePlaybackPosition(to: value):
			return handleSliderTouchedUp(state: &state, value: value)
			
		default:
			return .none
		}
	}
}

// MARK: - Supporting Methods

extension MediaPlayerStore {
	
	private func togglePlayPause() async throws {
		let isPlaying = await mediaPlayerClient.isPlaying()
		
		if isPlaying {
			try await mediaPlayerClient.pause()
		} else {
			try await mediaPlayerClient.play()
		}
	}
}

extension MediaPlayerStore.State {
	
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
