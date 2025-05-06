// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import Foundation

@DependencyClient
public struct TimerClient: Sendable {
	public var createTimer: @Sendable (_ id: TimerID, _ timeStep: TimeInterval, _ mode: TimerMode) async -> AsyncStream<TimerResult> = { _, _, _ in
		AsyncStream { _ in }
	}
	public var stopTimer: @Sendable (TimerID) async -> Void
	public var pauseTimer: @Sendable (TimerID) async -> Void
	public var resumeTimer: @Sendable (TimerID) async -> Void
	public var isTimerRunning: @Sendable (TimerID) async -> Bool = { _ in false }
}
