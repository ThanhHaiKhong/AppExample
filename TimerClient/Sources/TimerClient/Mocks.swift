//
//  Mocks.swift
//  TimerClient
//
//  Created by Thanh Hai Khong on 29/4/25.
//

import Dependencies

extension DependencyValues {
	public var timerClient: TimerClient {
		get { self[TimerClient.self] }
		set { self[TimerClient.self] = newValue }
	}
}

extension TimerClient: TestDependencyKey {
	
	public static let testValue = TimerClient(
		createTimer: { _, _, _ in AsyncStream { _ in } },
		stopTimer: { _ in },
		pauseTimer: { _ in },
		resumeTimer: { _ in },
		isTimerRunning: { _ in false }
	)
	
	public static let previewValue = TimerClient(
		createTimer: { _, _, _ in AsyncStream { _ in } },
		stopTimer: { _ in },
		pauseTimer: { _ in },
		resumeTimer: { _ in },
		isTimerRunning: { _ in false }
	)
}
