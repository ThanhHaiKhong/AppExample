// The Swift Programming Language
// https://docs.swift.org/swift-book

import DependenciesMacros
import Foundation

@DependencyClient
public struct PremiumGatewayClient: Sendable {
	public var listCampaigns: @Sendable (_ configuration: PremiumGatewayClient.ListConfiguration) async throws -> [PremiumGatewayClient.Campaign] = { _ in [] }
	public var verifyCampaign: @Sendable (_ configuration: PremiumGatewayClient.VerifyConfiguration) async throws -> Void = { _ in }
	public var invite: @Sendable (_ configuration: PremiumGatewayClient.InviteConfiguration) async throws -> PremiumGatewayClient.InviteResponse = { _ in .init(url: "") }
	public var checkEntitlements: @Sendable (_ configuration: PremiumGatewayClient.FeatureEntitlementConfiguration) async throws -> PremiumGatewayClient.FeatureEntitlementResponse = { _ in
		.init(expiredAt: Date(), timestamp: Date())
	}
	public var redeemCode: @Sendable (_ configuration: PremiumGatewayClient.RedeemConfiguration) async throws -> PremiumGatewayClient.RedeemResponse = { _ in
		.init(url: "", message: "", rid: "")
	}
}
