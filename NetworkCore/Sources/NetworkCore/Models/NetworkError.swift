//
//  NetworkError.swift
//  NetworkCore
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Foundation

public enum NetworkError: Error {
	case invalidResponse
	case serverError(statusCode: Int, data: Data?)
	case decodingError(Error)
	case unknown(Error)
}
