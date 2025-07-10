//
//  Mocks.swift
//  PremiumGatewayClient
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Dependencies

extension DependencyValues {
	public var premiumGatewayClient: PremiumGatewayClient {
		get { self[PremiumGatewayClient.self] }
		set { self[PremiumGatewayClient.self] = newValue }
	}
}

extension PremiumGatewayClient: TestDependencyKey {
	public static var testValue: PremiumGatewayClient {
		PremiumGatewayClient()
	}
	
	public static var previewValue: PremiumGatewayClient {
		PremiumGatewayClient()
	}
}
