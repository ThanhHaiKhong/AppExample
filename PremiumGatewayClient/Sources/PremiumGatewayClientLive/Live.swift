//
//  Live.swift
//  PremiumGatewayClient
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Dependencies
import PremiumGatewayClient

extension PremiumGatewayClient: DependencyKey {
	public static let liveValue = PremiumGatewayClient()
}
