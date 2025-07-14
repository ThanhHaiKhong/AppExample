//
//  Live.swift
//  PremiumGatewayClient
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Dependencies
import PremiumGatewayClient

extension PremiumGatewayClient: DependencyKey {
	public static var liveValue: PremiumGatewayClient {
		let actor = PremiumGatewayActor()
		return PremiumGatewayClient(
			listCampaigns: { configuration in
				try await actor.listCampaigns(configuration)
			},
			verifyCampaign: { configuration in
				try await actor.verifyCampaign(configuration)
			},
			invite: { configuration in
				try await actor.invite(configuration)
			},
			checkEntitlements: { configuration in
				try await actor.checkEntitlements(configuration)
			},
			redeemCode: { configuration in
				try await actor.redeemCode(configuration)
			}
		)
	}
}
