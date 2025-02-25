//
//  Live.swift
//  NotificationsClient
//
//  Created by Thanh Hai Khong on 10/2/25.
//

import ComposableArchitecture
import NotificationsClient
import FirebaseMessaging
import UIKit

extension NotificationsClient: DependencyKey {
    public static let liveValue: NotificationsClient = {
        return NotificationsClient(
            requestAuthorization: { options in
                return try await NotificationService.shared.requestAuthorization(options: options)
            },
            getNotifications: {
                return try await NotificationService.shared.getNotifications()
            },
            markAsRead: { id in
                return try await NotificationService.shared.markAsRead(id: id)
            },
            removeAllNotifications: {
                return await NotificationService.shared.removeAllNotifications()
            }
        )
    }()
}
