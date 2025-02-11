//
//  Mocks.swift
//  NotificationsClient
//
//  Created by Thanh Hai Khong on 10/2/25.
//

import ComposableArchitecture

extension NotificationsClient: TestDependencyKey {
    public static let testValue: NotificationsClient = {
        return Self(
            requestAuthorization: { options in
                return true
            },
            getNotifications: {
                return NotificationItem.mocks
            },
            markAsRead: { id in
                
            },
            removeAllNotifications: {
                
            }
        )
    }()
    
    public static let previewValue: NotificationsClient = {
        return Self(
            requestAuthorization: { options in
                return true
            },
            getNotifications: {
                return NotificationItem.mocks
            },
            markAsRead: { id in
                
            },
            removeAllNotifications: {
                
            }
        )
    }()
}
