//
//  Live.swift
//  TimerClient
//
//  Created by Thanh Hai Khong on 29/4/25.
//

import ComposableArchitecture
import TimerClient

extension TimerClient: DependencyKey {
	public static let liveValue: TimerClient = {
		let manager = TimerClientActor()
		return TimerClient(
			createTimer: { id, step, mode in
				await manager.createTimer(id: id, step: step, mode: mode)
			},
			stopTimer: { id in
				await manager.stopTimer(id: id)
			},
			pauseTimer: { id in
				await manager.pauseTimer(id: id)
			},
			resumeTimer: { id in
				await manager.resumeTimer(id: id)
			},
			isTimerRunning: { id in
				await manager.isTimerRunning(id: id)
			}
		)
	}()
}
