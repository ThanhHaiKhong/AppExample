//
//  ContentView.swift
//  NetworkPreview
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import AuthenticationCore
import NetworkCore
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
		.task {
			let tokenProvider = FirebaseTokenProvider()
			
			do {
				let token = try await tokenProvider.getToken()
				print("Token: \(token)")
			} catch {
				print("Failed to get token: \(error)")
			}
		}
    }
}

#Preview {
    ContentView()
}

public struct Campaign: Decodable {
	public let id: String
	public let name: String
	public let startDate: String
	public let endDate: String
}
/*
public struct ListCampaignsRequest: APIRequest {
	public var path: String { "campaigns" }
	public var method: HTTPMethod { .get }
	
	public var query: [String: String]?
	public var headers: [String: String]? = nil
	public var body: Data? = nil
	
	public init(namespace: String, bundle: String) {
		self.query = [
			"options.namespace": namespace,
			"options.bundle": bundle
		]
	}
}
*/
