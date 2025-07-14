//
//  Models.swift
//  PremiumGatewayClient
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Foundation
import NetworkClient

extension PremiumGatewayClient {
	public protocol APIConfigurable: Sendable {
		var token: String { get }
		var namespace: String { get }
		var bundle: String { get }
	}
}

extension PremiumGatewayClient {
	public struct ListConfiguration: APIConfigurable {
		public let token: String
		public let namespace: String
		public let bundle: String
		
		public init(
			token: String,
			namespace: String,
			bundle: String = Bundle.main.bundleIdentifier ?? ""
		) {
			self.token = token
			self.namespace = namespace
			self.bundle = bundle
		}
	}
}

extension PremiumGatewayClient.ListConfiguration {
	public var request: NetworkClient.Request {
		let endpoint = NetworkClient.Request.Endpoint(
			path: "/campaigns",
			method: .get,
			query: [
				"options.bundle": bundle,
				"options.namespace": namespace
			]
		)
		
		let payload = NetworkClient.Request.Payload(
			headers: [
				"Content-Type": "application/json",
				"Authorization" : "Bearer \(token)"
			]
		)
		
		let request = NetworkClient.Request(
			endpoint: endpoint,
			payload: payload,
			configuration: .default
		)
		return request
	}
}

extension PremiumGatewayClient {
	public struct CampaignListResponse: Decodable, Sendable {
		public let campaigns: [Campaign]
	}
	
	public struct Campaign: Decodable, Sendable {
		public let id: String
		public let mediaSource: String
		public let provider: String
		public let redeemId: String
		public let namespace: String
		public let bundles: [String]
		public let status: String
		public let name: String
		public let description: String
		public let createdAt: Date
		public let updatedAt: Date?
		
		enum CodingKeys: String, CodingKey {
			case id
			case mediaSource = "media_source"
			case provider
			case redeemId = "redeem_id"
			case namespace
			case bundles
			case status
			case name
			case description
			case createdAt = "created_at"
			case updatedAt = "updated_at"
		}
	}
}

extension PremiumGatewayClient {
	public struct VerifyConfiguration: APIConfigurable {
		public let token: String
		public let namespace: String
		public let bundle: String
		public let campaignId: String
		public let thirdPartyData: [String: AnyCodable]?
		
		public init(
			token: String,
			namespace: String,
			bundle: String,
			campaignId: String,
			thirdPartyData: [String: AnyCodable]? = nil
		) {
			self.token = token
			self.namespace = namespace
			self.bundle = bundle
			self.campaignId = campaignId
			self.thirdPartyData = thirdPartyData
		}
	}
}

extension PremiumGatewayClient.VerifyConfiguration {
	public var request: NetworkClient.Request {
		get throws {
			struct VerifyBody: Encodable {
				struct Options: Encodable {
					let namespace: String
					let bundle: String
				}
				
				let options: Options
				let data: [String: PremiumGatewayClient.AnyCodable]?
			}
			
			var anyCodableData: [String: PremiumGatewayClient.AnyCodable]? = nil
			if let data = thirdPartyData {
				anyCodableData = data.mapValues { PremiumGatewayClient.AnyCodable($0) }
			}
			
			let body = VerifyBody(
				options: .init(namespace: namespace, bundle: bundle),
				data: anyCodableData
			)
			
			let endpoint = NetworkClient.Request.Endpoint(
				path: "/campaigns/\(campaignId)/verify",
				method: .post
			)
			
			let payload = NetworkClient.Request.Payload(
				headers: [
					"Content-Type": "application/json",
					"Authorization": "Bearer \(token)"
				],
				body: try JSONEncoder().encode(body)
			)
			
			let request = NetworkClient.Request(endpoint: endpoint, payload: payload, configuration: .default)
			return request
		}
	}
}

extension PremiumGatewayClient {
	public struct InviteConfiguration: APIConfigurable {
		public let campaignId: String
		public let token: String
		public let namespace: String
		public let bundle: String
		
		public init(
			campaignId: String,
			token: String,
			namespace: String,
			bundle: String = Bundle.main.bundleIdentifier ?? ""
		) {
			self.campaignId = campaignId
			self.token = token
			self.namespace = namespace
			self.bundle = bundle
		}
	}
}

extension PremiumGatewayClient.InviteConfiguration {
	public var request: NetworkClient.Request {
		get throws {
			struct InviteBody: Encodable {
				let options: Options
				
				struct Options: Encodable {
					let namespace: String
					let bundle: String
				}
			}
			
			let body = InviteBody(
				options: .init(namespace: namespace, bundle: bundle)
			)
			
			let endpoint = NetworkClient.Request.Endpoint(
				path: "/campaigns/\(campaignId)/deep-link",
				method: .post
			)
			
			let payload = NetworkClient.Request.Payload(
				headers: [
					"Content-Type": "application/json",
					"Authorization": "Bearer \(token)"
				],
				body: try JSONEncoder().encode(body)
			)
			
			let request = NetworkClient.Request(
				endpoint: endpoint,
				payload: payload,
				configuration: .default
			)
			
			return request
		}
	}
}

extension PremiumGatewayClient {
	public struct InviteResponse: Decodable, Sendable {
		public let url: String
	}
}

// MARK: - PremiumGatewayClient.RedeemConfiguration

extension PremiumGatewayClient {
	public struct RedeemConfiguration: APIConfigurable {
		public let code: String
		public let userId: String
		public let token: String
		public let namespace: String
		public let bundle: String
		
		public init(
			code: String,
			userId: String,
			token: String,
			namespace: String,
			bundle: String = Bundle.main.bundleIdentifier ?? ""
		) {
			self.code = code
			self.userId = userId
			self.token = token
			self.namespace = namespace
			self.bundle = bundle
		}
	}
}

// MARK: - PremiumGatewayClient.RedeemConfiguration Request

extension PremiumGatewayClient.RedeemConfiguration {
	public var request: NetworkClient.Request {
		get throws {
			struct ActivateCodeBody: Encodable {
				let userId: String
				let refId: String
				let methodId: String
				let options: Options
				
				struct Options: Encodable {
					let namespace: String
					let bundle: String
				}
				
				enum CodingKeys: String, CodingKey {
					case userId = "uid"
					case refId = "ref_id"
					case methodId = "mid"
					case options
				}
			}
			
			let body = ActivateCodeBody(
				userId: userId,
				refId: userId,
				methodId: "redeem",
				options: .init(namespace: namespace, bundle: bundle)
			)
			
			let endpoint = NetworkClient.Request.Endpoint(
				path: "/payment/redeems/\(code)/use",
				method: .post
			)
			
			let payload = NetworkClient.Request.Payload(
				headers: [
					"Content-Type": "application/json",
					"Authorization": "Bearer \(token)"
				],
				body: try JSONEncoder().encode(body)
			)
			
			let request = NetworkClient.Request(
				endpoint:  endpoint,
				payload: payload,
				configuration: .default
			)
			
			return request
		}
	}
}

// MARK: - PremiumGatewayClient.RedeemResponse

extension PremiumGatewayClient {
	public struct RedeemResponse: Decodable, Sendable {
		public let url: String
		public let message: String
		public let rid: String
		
		public init(
			url: String,
			message: String,
			rid: String
		) {
			self.url = url
			self.message = message
			self.rid = rid
		}
	}
}

// MARK: - PremiumGatewayClient

extension PremiumGatewayClient {
	public struct FeatureEntitlementConfiguration: APIConfigurable {
		public let refId: String
		public let features: [Feature]
		public let token: String
		public let namespace: String
		public let bundle: String
		
		public enum Feature: Int, Sendable {
			case none = 0
			case removeAds = 1
		}
		
		public init(
			refId: String,
			features: [Feature],
			token: String,
			namespace: String,
			bundle: String = Bundle.main.bundleIdentifier ?? ""
		) {
			self.refId = refId
			self.features = features
			self.token = token
			self.namespace = namespace
			self.bundle = bundle
		}
	}
}

extension PremiumGatewayClient.FeatureEntitlementConfiguration {
	public var request: NetworkClient.Request {
		let functionValues = features.map { String($0.rawValue) }.joined(separator: ",")
		
		let endpoint = NetworkClient.Request.Endpoint(
			path: "/payment/activation-functions",
			method: .get,
			query: [
				"ref_id": refId,
				"functions": functionValues,
				"options.namespace": namespace,
				"options.bundle": bundle
			]
		)
		
		let payload = NetworkClient.Request.Payload(
			headers: [
				"Content-Type": "application/json",
				"Authorization": "Bearer \(token)"
			]
		)
		
		let request = NetworkClient.Request(
			endpoint: endpoint,
			payload: payload,
			configuration: .default
		)
		
		return request
	}
}

// MARK: - PremiumGatewayClient.FunctionResponse

extension PremiumGatewayClient {
	public struct FeatureEntitlementResponse: Decodable, Sendable {
		public let expiredAt: Date
		public let timestamp: Date
		
		enum CodingKeys: String, CodingKey {
			case expiredAt = "expired_at"
			case timestamp
		}
	}
}

// MARK: - AnyCodable

extension PremiumGatewayClient {
	public struct AnyCodable: Codable, @unchecked Sendable {
		public let value: Any
		
		public init(_ value: Any) {
			self.value = value
		}
		
		public init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			
			if let intVal = try? container.decode(Int.self) {
				self.value = intVal
			} else if let doubleVal = try? container.decode(Double.self) {
				self.value = doubleVal
			} else if let boolVal = try? container.decode(Bool.self) {
				self.value = boolVal
			} else if let stringVal = try? container.decode(String.self) {
				self.value = stringVal
			} else if let arrayVal = try? container.decode([AnyCodable].self) {
				self.value = arrayVal.map(\.value)
			} else if let dictVal = try? container.decode([String: AnyCodable].self) {
				self.value = dictVal.mapValues(\.value)
			} else {
				throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON type")
			}
		}
		
		public func encode(to encoder: Encoder) throws {
			var container = encoder.singleValueContainer()
			
			switch value {
			case let intVal as Int:
				try container.encode(intVal)
			case let doubleVal as Double:
				try container.encode(doubleVal)
			case let boolVal as Bool:
				try container.encode(boolVal)
			case let stringVal as String:
				try container.encode(stringVal)
			case let arrayVal as [Any]:
				try container.encode(arrayVal.map(AnyCodable.init))
			case let dictVal as [String: Any]:
				try container.encode(dictVal.mapValues(AnyCodable.init))
			default:
				throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid JSON value"))
			}
		}
	}
}
