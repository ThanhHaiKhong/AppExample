// The Swift Programming Language
// https://docs.swift.org/swift-book

import DependenciesMacros
import AVKit

@DependencyClient
public struct NowPlayingClient: Sendable {
	public var initializeAudioSession: @Sendable (_ category: AVAudioSession.Category, _ mode: AVAudioSession.Mode, _ options: AVAudioSession.CategoryOptions) async throws -> Void
	public var registerRemoteCommandEvents: @Sendable (_ enabledCommands: Set<RemoteCommand>) async -> AsyncStream<NowPlayingClient.RemoteCommandEvent> = { _ in AsyncStream { _ in } }
	public var interruptionEvents: @Sendable () async -> AsyncStream<NowPlayingClient.InterruptionEvent> = { AsyncStream { _ in } }
	public var updateStaticInfo: @Sendable (_ info: NowPlayingClient.StaticNowPlayingInfo) async throws -> Void
	public var updateDynamicInfo: @Sendable (_ info: NowPlayingClient.DynamicNowPlayingInfo) async throws -> Void
}
