//
//  NotificationService.swift
//  NotificationsClient
//
//  Created by Thanh Hai Khong on 10/2/25.
//

import NotificationsClient
import FirebaseMessaging
import FirebaseFirestore
import FirebaseCore
import UIKit

final class NotificationService: NSObject, @unchecked Sendable {
    static let shared = NotificationService()
    
    private override init() {
        super.init()
    }
}

// MARK: - Pulic Methods

extension NotificationService {
    public func configure() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        FirebaseApp.configure()
    }
    
    public func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    public func getNotifications() async throws -> [NotificationItem] {
        // Giả sử bạn lưu trữ thông báo trong Firestore hoặc Realtime Database
        // Lấy dữ liệu từ Firestore và chuyển thành dạng NotificationItem
        // Ví dụ với Firestore (bạn có thể thay đổi theo cách bạn lưu trữ thông báo)
        let db = Firestore.firestore()
        let snapshot = try await db.collection("notifications").getDocuments()
        var notifications: [NotificationItem] = []
        
        for document in snapshot.documents {
            let data = document.data()
            let id = document.documentID
            if let title = data["title"] as? String,
               let body = data["body"] as? String,
               let timestamp = data["timestamp"] as? Timestamp {
                let notification = NotificationItem(id: id, title: title, body: body, imageURL: nil, status: false, timestamp: timestamp.dateValue())
                notifications.append(notification)
            }
        }
        
        return NotificationItem.mocks
    }
    
    public func markAsRead(id: String) async throws {
        let db = Firestore.firestore()
        try await db.collection("notifications").document(id).updateData(["status": "read"])
    }
    
    public func removeAllNotifications() async {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}

// MARK: - Private Methods

extension NotificationService {
    
}

// MARK: - MessagingDelegate

extension NotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "Không có")")
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let content = notification.request.content
        let userInfo = content.userInfo
        print("Nhận thông báo: \(userInfo)")
        completionHandler([.banner, .sound])
    }
}
