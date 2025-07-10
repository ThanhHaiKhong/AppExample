//
//  TokenStorage.swift
//  NetworkCore
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Foundation
import Security

public protocol TokenStorage {
	func read() -> String?
	func save(token: String)
	func clear()
}

public final class InMemoryTokenStorage: TokenStorage {
	private var token: String?
	
	public init() {
		
	}
	
	public func read() -> String? {
		token
	}
	
	public func save(token: String) {
		self.token = token
	}
	
	public func clear() {
		token = nil
	}
}

public final class UserDefaultsTokenStorage: TokenStorage {
	private let key: String
	private let defaults: UserDefaults
	
	public init(key: String = "auth_token", suiteName: String? = nil) {
		self.key = key
		self.defaults = suiteName != nil
		? UserDefaults(suiteName: suiteName)!
		: .standard
	}
	
	public func read() -> String? {
		defaults.string(forKey: key)
	}
	
	public func save(token: String) {
		defaults.set(token, forKey: key)
	}
	
	public func clear() {
		defaults.removeObject(forKey: key)
	}
}

public final class KeychainTokenStorage: TokenStorage {
	private let service: String
	private let account: String
	private let accessGroup: String?
	
	public init(account: String = "auth_token", service: String = "com.yourcompany.networkcore", accessGroup: String? = nil) {
		self.account = account
		self.service = service
		self.accessGroup = accessGroup
	}
	
	public func read() -> String? {
		var query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: account,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne
		]
		if let group = accessGroup {
			query[kSecAttrAccessGroup as String] = group
		}
		
		var item: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &item)
		
		if status == errSecSuccess, let data = item as? Data {
			return String(data: data, encoding: .utf8)
		} else {
			print("Keychain read failed with status: \(status)")
		}
		return nil
	}
	
	public func save(token: String) {
		let data = token.data(using: .utf8)!
		var query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: account
		]
		if let group = accessGroup {
			query[kSecAttrAccessGroup as String] = group
		}
		SecItemDelete(query as CFDictionary)
		var attributes: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: account,
			kSecValueData as String: data
		]
		if let group = accessGroup {
			attributes[kSecAttrAccessGroup as String] = group
		}
		let status = SecItemAdd(attributes as CFDictionary, nil)
		if status != errSecSuccess {
			print("Keychain save failed with status: \(status)")
		}
	}
	
	public func clear() {
		var query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: account
		]
		if let group = accessGroup {
			query[kSecAttrAccessGroup as String] = group
		}
		SecItemDelete(query as CFDictionary)
	}
}
