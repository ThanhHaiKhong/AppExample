import Dependencies
import Testing
@testable import NetworkClient

@Dependency(\.networkClient) var networkClient

@Test
func authenticate() async throws {
	let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjQ3YWU0OWM0YzlkM2ViODVhNTI1NDA3MmMzMGQyZThlNzY2MWVmZTEiLCJ0eXAiOiJKV1QifQ.eyJwcm92aWRlcl9pZCI6ImFub255bW91cyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9sN21vYmlsZS1hcHBzIiwiYXVkIjoibDdtb2JpbGUtYXBwcyIsImF1dGhfdGltZSI6MTc0OTAwNjQ0NywidXNlcl9pZCI6Ikl0a3FRRjc3R2FUOHZWTXJmSEU4WUpnUTVFZzIiLCJzdWIiOiJJdGtxUUY3N0dhVDh2Vk1yZkhFOFlKZ1E1RWcyIiwiaWF0IjoxNzUyMjgxODc4LCJleHAiOjE3NTIyODU0NzgsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnt9LCJzaWduX2luX3Byb3ZpZGVyIjoiYW5vbnltb3VzIn19.Yr1y25mtxcOxMgKTgqRxQfp8FXweqnv3Y--7pjtA3a4ziYbirC3p_SUVBOEmHM_A6I_7xnSf1nUrKYPSQhhAnB1jsXKhE9nO15oUDDkYWBqxr_LBiNSXZ6iaH6jw1rqt00nCzcWfPO9WV5TBdeBcgSB8mytMvN-NJchgMNNlkCHYyw_ScX0JKoFPb2H97xCClzFQqym5X_vxMz355r51ID2S9ckWpQUFFMIkpCJr7VSevF50h1d1sVWJc8AyKj_imPC0kHPB_P1MhzN73-8Fdg89xgrjL2KO-0d7zA-woPxhI8qDH1zqldh20F_0Z4YCVJGtGK97q5t31fJ0G3Xs_g"
	let options: [String: String] = [
		"bundle": "com.simpleapp.simplemusic",
		"namespace": "l7mobile",
	]
	
	let authRequest = NetworkClient.AuthRequest(
		kind: .firebase(token: token, expiry: 3600, options: options)
	)
	
	let response = try await networkClient.authenticate(authRequest)
	let decoded = try response.decode(NetworkClient.AuthResponse.self)
	#expect(!decoded.token.accessToken.isEmpty)
	#expect(response.metadata.status == true)
	#expect(response.rawData != nil)
}
