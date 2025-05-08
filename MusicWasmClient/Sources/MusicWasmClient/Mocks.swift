//
//  Mocks.swift
//  MusicWasmClient
//
//  Created by Thanh Hai Khong on 8/5/25.
//

import Dependencies

extension DependencyValues {
	public var musicWasmClient: MusicWasmClient {
		get { self[MusicWasmClient.self] }
		set { self[MusicWasmClient.self] = newValue }
	}
}

extension MusicWasmClient: TestDependencyKey {
	
	public static let testValue = MusicWasmClient()
	
	public static let previewValue = MusicWasmClient()
}
