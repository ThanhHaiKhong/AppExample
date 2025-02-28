//
//  NotificationView.swift
//  Example
//
//  Created by Thanh Hai Khong on 10/2/25.
//

import ComposableArchitecture
import NotificationsClient
import SwiftUI

public struct NotificationView: View {
    @Perception.Bindable private var store: StoreOf<Notifications>
    private let imageSize: CGFloat = 55.0
    private let cornerRadius: CGFloat = 5.0
    
    public init(store: StoreOf<Notifications>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack {
                List {
                    ForEach(store.notifications) { notification in
                        HStack(spacing: 12) {
                            if let url = notification.imageURL {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                        .scaleEffect(0.75)
                                }
                                .frame(width: imageSize, height: imageSize)
                                .background(.thinMaterial)
                                .clipShape(.rect(cornerRadius: cornerRadius))
                            } else {
                                Image(systemName: "bell.fill")
                                    .font(.title3)
                                    .frame(width: imageSize, height: imageSize)
                                    .background(.red.opacity(0.25))
                                    .foregroundStyle(.red)
                                    .clipShape(.rect(cornerRadius: cornerRadius))
                            }
                            
                            VStack(alignment: .leading) {
                                Text(notification.title)
                                    .font(.headline)
                                    .foregroundStyle(notification.status ? .secondary : .primary)
                                    .lineLimit(2)
                                
                                Text(notification.body)
                                    .font(.subheadline)
                                    .foregroundStyle(notification.status ? .secondary : .primary)
                                    .lineLimit(2)
                                
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(notification.timestamp, style: .relative)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.top, 2)
                            }
                            
                            Spacer()
                        }
                        .overlay(alignment: .topTrailing) {
                            if !notification.status {
                                Image(systemName: "circle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundStyle(.red)
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "trash")
                            .font(.headline)
                            .foregroundStyle(.red)
                    }
                }
            }
            .task {
                store.send(.view(.onTask))
            }
        }
    }
}
