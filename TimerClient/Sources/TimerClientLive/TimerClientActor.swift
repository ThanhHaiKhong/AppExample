//
//  TimerClientActor.swift
//  TimerClient
//
//  Created by Thanh Hai Khong on 1/5/25.
//

import TimerClient
import Foundation

actor TimerClientActor {
	private struct TimerInfo: Sendable {
		let taskID: UUID
		let task: Task<Void, Never>
		var startTime: Date
		var pausedAt: Date?
		var accumulatedPauseDuration: TimeInterval
		let continuation: AsyncStream<TimerClient.TimerResult>.Continuation
		let mode: TimerClient.TimerMode
	}
	
	private var timers: [TimerClient.TimerID: TimerInfo] = [:]
	
	func createTimer(id: TimerClient.TimerID, step: TimeInterval, mode: TimerClient.TimerMode) -> AsyncStream<TimerClient.TimerResult> {
		return AsyncStream { continuation in
			Task {
				let taskID = UUID()
				await stopTimer(id: id)
				print("⏰ Timer with ID \(id) STARTED.")
				let startTime = Date()
				let task = Task {
					while !Task.isCancelled {
						guard let timer = timers[id] else { break }
						
						let now = Date()
						let pauseDuration = timer.pausedAt.map { now.timeIntervalSince($0) } ?? 0
						let effectiveStartTime = timer.startTime.addingTimeInterval(timer.accumulatedPauseDuration)
						let elapsed = now.timeIntervalSince(effectiveStartTime) - pauseDuration
						
						let output: TimeInterval
						switch mode {
						case .regular:
							output = elapsed
						case .countdown(let total):
							output = max(0, total - elapsed)
							if output < 0 {
								continuation.yield(.completed)
								await stopTimer(id: id)
								return
							}
						}
						
						continuation.yield(.tick(output))
						try? await Task.sleep(nanoseconds: UInt64(step * 1_000_000_000))
					}
					
					continuation.finish()
				}
				
				timers[id] = TimerInfo(
					taskID: taskID,
					task: task,
					startTime: startTime,
					pausedAt: nil,
					accumulatedPauseDuration: 0,
					continuation: continuation,
					mode: mode
				)
				
				continuation.onTermination = { [weak self] _ in
					Task {
						guard let `self` = self,
							  let current = await self.timers[id],
							  current.taskID == taskID
						else {
							return
						}
						
						await self.stopTimer(id: id)
					}
				}
			}
		}
	}
	
	func stopTimer(id: TimerClient.TimerID) async {
		guard let info = timers.removeValue(forKey: id) else { return }
		info.task.cancel()
		info.continuation.finish()
		print("⏰ Timer with ID \(id) STOPPED.")
	}
	
	func pauseTimer(id: TimerClient.TimerID) async {
		guard var info = timers[id], info.pausedAt == nil else { return }
		info.pausedAt = Date()
		timers[id] = info
	}
	
	func resumeTimer(id: TimerClient.TimerID) async {
		guard var info = timers[id], let pausedAt = info.pausedAt else { return }
		let pausedDuration = Date().timeIntervalSince(pausedAt)
		info.accumulatedPauseDuration += pausedDuration
		info.pausedAt = nil
		timers[id] = info
	}
	
	func isTimerRunning(id: TimerClient.TimerID) async -> Bool {
		guard let info = timers[id] else { return false }
		return info.pausedAt == nil
	}
	
	func getElapsedTime(id: TimerClient.TimerID) -> TimeInterval? {
		guard let info = timers[id] else { return nil }
		
		let now = Date()
		let pausedDuration = info.pausedAt.map { now.timeIntervalSince($0) } ?? 0
		let effectiveStartTime = info.startTime.addingTimeInterval(info.accumulatedPauseDuration)
		let elapsed = now.timeIntervalSince(effectiveStartTime) - pausedDuration
		
		switch info.mode {
		case .regular:
			return elapsed
		case .countdown(let total):
			return max(0, total - elapsed)
		}
	}
}
