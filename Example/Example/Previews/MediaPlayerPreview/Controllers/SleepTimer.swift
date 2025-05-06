//
//  SleepTimer.swift
//  Example
//
//  Created by Thanh Hai Khong on 30/4/25.
//

import ComposableArchitecture
import TimerClient
import Foundation

@Reducer
public struct SleepTimer: Sendable {
	@ObservableState
	public struct State: Sendable, Equatable {
		public var timerID: TimerClient.TimerID = .init(rawValue: "sleep_timer_identifier")
		public var sleepMode: PlayerStore.State.SleepMode = .off
		public var isTimerRunning: Bool = false
		public var remainingTime: TimeInterval?
		public var timeStep: TimeInterval = 1
		
		public init() {}
	}
	
	public enum Action: Sendable, Equatable {
		case setSleepMode(PlayerStore.State.SleepMode)
		case stopTimer
		case tick(TimeInterval)
		case timerDidFinish
	}
	
	@Dependency(\.timerClient) var timerClient
	
	public var body: some Reducer<State, Action> {
		Reduce { state, action in
			switch action {
			case let .setSleepMode(sleepMode):
				state.sleepMode = sleepMode
				
				switch sleepMode {
				case .off:
					state.isTimerRunning = false
					return .run { [timerID = state.timerID] send in
						await timerClient.stopTimer(timerID)
					}
					
				default:
					state.isTimerRunning = true
					state.remainingTime = nil
					return .run { [id = state.timerID, step = state.timeStep] send in
						let mode: TimerClient.TimerMode = .countdown(sleepMode.duration)
						for await timerResult in await timerClient.createTimer(id, step, mode) {
							switch timerResult {
							case let .tick(remainingTime):
								await send(.tick(remainingTime))
								
							case .completed:
								await send(.timerDidFinish)
								
							default:
								break
							}
						}
					}
				}
				
			case .stopTimer:
				state.isTimerRunning = false
				return .run { [timerID = state.timerID] send in
					await timerClient.stopTimer(timerID)
				}
				
			case let .tick(remainingTime):
				state.remainingTime = remainingTime
				return .none
				
			case .timerDidFinish:
				state.isTimerRunning = false
				state.remainingTime = nil
				return .none
			}
		}
	}
	
	public init() { }
}
