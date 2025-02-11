// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import UserNotifications
import Foundation

@DependencyClient
public struct NotificationsClient: Sendable {
    public var requestAuthorization: @Sendable (_ options: UNAuthorizationOptions) async throws -> Bool
    public var getNotifications: @Sendable () async throws -> [NotificationItem]
    public var markAsRead: @Sendable (_ id: String) async throws -> Void
    public var removeAllNotifications: @Sendable () async -> Void
}

extension DependencyValues {
    public var notificationsClient: NotificationsClient {
        get { self[NotificationsClient.self] }
        set { self[NotificationsClient.self] = newValue }
    }
}
