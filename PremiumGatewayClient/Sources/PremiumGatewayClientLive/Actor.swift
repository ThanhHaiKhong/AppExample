//
//  Actor.swift
//  PremiumGatewayClient
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Foundation
import NetworkCore

private final class PremiumGatewayManager: NSObject {
	
	override init() {
		super.init()
		
		let tokenProvider = FirebaseTokenProvider()
		Task {
			let token = try? await tokenProvider.getToken()
		}
	}
}
