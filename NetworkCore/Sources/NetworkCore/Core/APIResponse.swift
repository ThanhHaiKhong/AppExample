//
//  APIResponse.swift
//  NetworkCore
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Foundation

public struct APIResponse<T: Decodable>: Decodable {
	public let status: Bool
	public let message: String?
	public let data: T?
	
	public init(status: Bool, message: String?, data: T?) {
		self.status = status
		self.message = message
		self.data = data
	}
}
