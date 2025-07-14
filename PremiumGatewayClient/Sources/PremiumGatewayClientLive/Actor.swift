//
//  Actor.swift
//  PremiumGatewayClient
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import PremiumGatewayClient
import NetworkClient
import Dependencies
import Foundation

public actor PremiumGatewayActor {
	
	// MARK: - Properties
	
	private let manager: PremiumGatewayManager
	
	// MARK: - Initialization
	
	public init() {
		self.manager = PremiumGatewayManager()
	}
	
	// MARK: - Public Methods
	
	public func listCampaigns(_ configuration: PremiumGatewayClient.ListConfiguration) async throws -> [PremiumGatewayClient.Campaign] {
		try await manager.listCampaigns(configuration)
	}
	
	public func verifyCampaign(_ configuration: PremiumGatewayClient.VerifyConfiguration) async throws {
		try await manager.verifyCampaign(configuration)
	}
	
	public func invite(_ configuration: PremiumGatewayClient.InviteConfiguration) async throws -> PremiumGatewayClient.InviteResponse {
		try await manager.invite(configuration)
	}
	
	public func checkEntitlements(_ configuration: PremiumGatewayClient.FeatureEntitlementConfiguration) async throws -> PremiumGatewayClient.FeatureEntitlementResponse {
		try await manager.checkEntitlements(configuration)
	}
	
	public func redeemCode(_ configuration: PremiumGatewayClient.RedeemConfiguration) async throws -> PremiumGatewayClient.RedeemResponse {
		try await manager.redeemCode(configuration)
	}
}

private final class PremiumGatewayManager: @unchecked Sendable {
	
	@Dependency(\.networkClient) private var networkClient
	
	public func listCampaigns(_ configuration: PremiumGatewayClient.ListConfiguration) async throws -> [PremiumGatewayClient.Campaign] {
		let response = try await networkClient.send(configuration.request)
		if !response.metadata.status {
			throw NetworkClient.Error.invalidResponse
		}
		
		guard let data = response.rawData else {
			throw NetworkClient.Error.invalidResponse
		}
		
		do {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let listResponse = try decoder.decode(PremiumGatewayClient.CampaignListResponse.self, from: data)
			return listResponse.campaigns
		} catch {
			throw NetworkClient.Error.decodingError(error)
		}
	}
	
	public func verifyCampaign(_ configuration: PremiumGatewayClient.VerifyConfiguration) async throws -> Void {
		let request = try configuration.request
		let response = try await networkClient.send(request)
		print("🗳️ PREMIUM_GATEWAY campaign verification response: \(response)")
	}
	
	public func invite(_ configuration: PremiumGatewayClient.InviteConfiguration) async throws -> PremiumGatewayClient.InviteResponse {
		let request = try configuration.request
		let response = try await networkClient.send(request)
		
		guard let data = response.rawData else {
			throw NetworkClient.Error.invalidResponse
		}
		
		do {
			let decoder = JSONDecoder()
			let inviteResponse = try decoder.decode(PremiumGatewayClient.InviteResponse.self, from: data)
			return inviteResponse
		} catch {
			throw NetworkClient.Error.decodingError(error)
		}
	}
	
	public func checkEntitlements(_ configuration: PremiumGatewayClient.FeatureEntitlementConfiguration) async throws -> PremiumGatewayClient.FeatureEntitlementResponse {
		let request = configuration.request
		let response = try await networkClient.send(request)
		
		guard let data = response.rawData else {
			throw NetworkClient.Error.invalidResponse
		}
		
		do {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .rfc3339Flexible
			let entitlementResponse = try decoder.decode(PremiumGatewayClient.FeatureEntitlementResponse.self, from: data)
			return entitlementResponse
		} catch {
			throw NetworkClient.Error.decodingError(error)
		}
	}
	
	public func redeemCode(_ configuration: PremiumGatewayClient.RedeemConfiguration) async throws -> PremiumGatewayClient.RedeemResponse {
		let request = try configuration.request
		let response = try await networkClient.send(request)
		
		guard let data = response.rawData else {
			throw NetworkClient.Error.invalidResponse
		}
		
		do {
			let decoder = JSONDecoder()
			let redeemResponse = try decoder.decode(PremiumGatewayClient.RedeemResponse.self, from: data)
			return redeemResponse
		} catch {
			throw NetworkClient.Error.decodingError(error)
		}
	}
}

extension JSONDecoder.DateDecodingStrategy {
	static var rfc3339Flexible: JSONDecoder.DateDecodingStrategy {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [
			.withInternetDateTime,
			.withFractionalSeconds
		]
		return .custom { decoder in
			let container = try decoder.singleValueContainer()
			let dateStr = try container.decode(String.self)
			
			if let date = formatter.date(from: dateStr) {
				return date
			} else {
				throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid RFC3339 date: \(dateStr)")
			}
		}
	}
}
