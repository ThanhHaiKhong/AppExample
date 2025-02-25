//
//  NotificationItem.swift
//  NotificationsClient
//
//  Created by Thanh Hai Khong on 10/2/25.
//

import Foundation

public struct NotificationItem: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let body: String
    public let imageURL: URL?
    public let status: Bool
    public let timestamp: Date
    
    public init(id: String, title: String, body: String, imageURL: URL?, status: Bool, timestamp: Date) {
        self.id = id
        self.title = title
        self.body = body
        self.imageURL = imageURL
        self.status = status
        self.timestamp = timestamp
    }
    
    public static let mocks: [NotificationItem] = [
        NotificationItem(
            id: "1",
            title: "New Playlist Available",
            body: "Check out our new playlist 'Chill Beats' to relax to your favorite tunes.",
            imageURL: URL(string: "https://yavuzceliker.github.io/sample-images/image-1.jpg"),
            status: false,
            timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
        ),
        NotificationItem(
            id: "2",
            title: "Upcoming Concert",
            body: "Don't miss out! Your favorite band is performing live tomorrow.",
            imageURL: nil,
            status: true,
            timestamp: Date().addingTimeInterval(-7200) // 2 hours ago
        ),
        NotificationItem(
            id: "3",
            title: "New Album Release",
            body: "The new album by Taylor Swift has just dropped. Listen now!",
            imageURL: URL(string: "https://yavuzceliker.github.io/sample-images/image-3.jpg"),
            status: false,
            timestamp: Date().addingTimeInterval(-18000) // 5 hours ago
        ),
        NotificationItem(
            id: "4",
            title: "Exclusive Offer",
            body: "Get 30% off your next subscription if you renew today!",
            imageURL: URL(string: "https://yavuzceliker.github.io/sample-images/image-4.jpg"),
            status: true,
            timestamp: Date().addingTimeInterval(-86400) // 1 day ago
        ),
        NotificationItem(
            id: "5",
            title: "Reminder: Playlist Session",
            body: "Your 'Morning Vibes' playlist session starts at 8:00 AM. Get ready!",
            imageURL: URL(string: "https://yavuzceliker.github.io/sample-images/image-5.jpg"),
            status: false,
            timestamp: Date().addingTimeInterval(-43200) // 12 hours ago
        ),
        NotificationItem(
            id: "6",
            title: "Artist Update",
            body: "New tracks are available from your favorite artist, Ed Sheeran.",
            imageURL: URL(string: "https://yavuzceliker.github.io/sample-images/image-6.jpg"),
            status: true,
            timestamp: Date().addingTimeInterval(-172800) // 2 days ago
        ),
        NotificationItem(
            id: "7",
            title: "New Feature Available",
            body: "Try out our new feature 'Lyrics' to sing along with your favorite songs.",
            imageURL: URL(string: "https://yavuzceliker.github.io/sample-images/image-7.jpg"),
            status: false,
            timestamp: Date().addingTimeInterval(-259200) // 3 days ago
        ),
        NotificationItem(
            id: "8",
            title: "Concert Tickets",
            body: "Get your tickets for the upcoming concert before they sell out!",
            imageURL: URL(string: "https://yavuzceliker.github.io/sample-images/image-8.jpg"),
            status: true,
            timestamp: Date().addingTimeInterval(-345600) // 4 days ago
        ),
        NotificationItem(
            id: "9",
            title: "New Playlist Available",
            body: "Check out our new playlist 'Chill Beats' to relax to your favorite tunes.",
            imageURL: URL(string: "https://yavuzceliker.github.io/sample-images/image-9.jpg"),
            status: false,
            timestamp: Date().addingTimeInterval(-432000) // 5 days ago
        ),
        NotificationItem(
            id: "10",
            title: "Upcoming Concert",
            body: "Don't miss out! Your favorite band is performing live tomorrow.",
            imageURL: URL(string: "https://yavuzceliker.github.io/sample-images/image-10.jpg"),
            status: true,
            timestamp: Date().addingTimeInterval(-518400) // 6 days ago
        ),
        NotificationItem(
            id: "11",
            title: "New Album Release",
            body: "The new album by Taylor Swift has just dropped. Listen now!",
            imageURL: URL(string: "https://yavuzceliker.github.io/sample-images/image-11.jpg"),
            status: false,
            timestamp: Date().addingTimeInterval(-604800) // 1 week ago
        ),
        NotificationItem(
            id: "12",
            title: "Exclusive Offer",
            body: "Get 30% off your next subscription if you renew today!",
            imageURL: URL(string: "https://yavuzceliker.github.io/sample-images/image-12.jpg"),
            status: true,
            timestamp: Date().addingTimeInterval(-691200) // 8 days ago
        ),
        NotificationItem(
            id: "13",
            title: "Reminder: Playlist Session",
            body: "Your 'Morning Vibes' playlist session starts at 8:00 AM. Get ready!",
            imageURL: URL(string: "https://yavuzceliker.github.io/sample-images/image-13.jpg"),
            status: false,
            timestamp: Date().addingTimeInterval(-777600) // 9 days ago
        ),
        NotificationItem(
            id: "14",
            title: "Artist Update",
            body: "New tracks are available from your favorite artist, Ed Sheeran.",
            imageURL: URL(string: "https://yavuzceliker.github.io/sample-images/image-14.jpg"),
            status: true,
            timestamp: Date().addingTimeInterval(-864000) // 10 days ago
        ),
    ]
}
