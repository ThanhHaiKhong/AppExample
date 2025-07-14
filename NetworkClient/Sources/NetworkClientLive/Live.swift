//
//  Live.swift
//  NetworkClient
//
//  Created by Thanh Hai Khong on 11/7/25.
//

import Dependencies
import NetworkClient

extension NetworkClient: DependencyKey {
	public static let liveValue: NetworkClient = {
		let actor = NetworkActor()
		return NetworkClient(
			authenticate: { request in
				try await actor.authenticate(request)
			},
			send: { request in
				try await actor.send(request)
			},
		)
	}()
}
