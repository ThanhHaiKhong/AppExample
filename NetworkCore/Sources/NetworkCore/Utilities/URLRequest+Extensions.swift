//
//  URLRequest+Extensions.swift
//  NetworkCore
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Foundation

extension URLRequest {
	public func prettyDescription() -> String {
		return """
		\(httpMethod ?? "") \(url?.absoluteString ?? "")
		Headers: \(allHTTPHeaderFields ?? [:])
		Body: \(String(data: httpBody ?? Data(), encoding: .utf8) ?? "")
		"""
			.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
