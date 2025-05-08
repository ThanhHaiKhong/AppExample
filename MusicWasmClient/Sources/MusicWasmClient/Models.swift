//
//  Models.swift
//  MusicWasmClient
//
//  Created by Thanh Hai Khong on 8/5/25.
//

import Foundation

extension MusicWasmClient {
	
	public enum EngineState: Sendable, Equatable {
		case idle
		case loading
		case loaded
		case error(Error)
		
		public static func == (lhs: EngineState, rhs: EngineState) -> Bool {
			switch (lhs, rhs) {
			case (.idle, .idle), (.loading, .loading), (.loaded, .loaded):
				return true
			case (.error(let lhsError), .error(let rhsError)):
				return lhsError.localizedDescription == rhsError.localizedDescription
			default:
				return false
			}
		}
	}
}
