//
//  MobilePlatformUI.swift
//  MobilePlatform
//
//  Created by Thanh Hai Khong on 3/10/24.
//

import ComposableArchitecture
import UIConstants
import UIModifiers
import Kingfisher
import SwiftUI

@available(iOS 16.0, *)
public struct EditorChoiceCardView: View {
    private let store: StoreOf<EditorChoiceCard>
    private let edgePadding: CGFloat = 12
    private let artworkSize: CGFloat = 40
    
    public init(store: StoreOf<EditorChoiceCard>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            RoundedRectangle(cornerRadius: UIConstants.Layers.cornerRadius)
                .fill(.thinMaterial)
                .frame(width: screenSize.width - UIConstants.Padding.horizontal * 2, height: (screenSize.width - UIConstants.Padding.horizontal * 2) / 1.4)
                .overlay {
                    KFImage(store.item.artworkURL)
                        .resizable()
                        .loadDiskFileSynchronously()
                        .cacheMemoryOnly()
                        .fade(duration: 0.25)
                        .placeholder {
                            ProgressView()
                                .padding(.bottom, 32)
                        }
                }
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: artworkSize + edgePadding * 2)
                        .overlay {
                            HStack {
                                KFImage(store.item.miniIconURL)
                                    .resizable()
                                    .loadDiskFileSynchronously()
                                    .cacheMemoryOnly()
                                    .fade(duration: 0.25)
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(width: artworkSize, height: artworkSize)
                                    .clipShape(.rect(cornerRadius: 5))
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(store.item.title ?? "")
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    
                                    Text(store.item.description ?? "")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Button {
                                    if let url = store.item.appStoreURL {
                                        store.send(.openURL(url))
                                    }
                                } label: {
                                    Text("FREE")
                                        .font(.system(.footnote, design: .monospaced).weight(.bold))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, edgePadding)
                                        .background(.blue, in: .capsule)
                                }
                            }
                            .padding(.horizontal, edgePadding)
                        }
                        .cornerRadius(UIConstants.Layers.cornerRadius, corners: [.bottomLeft, .bottomRight])
                }
                .contentShape(.rect)
                .clipShape(.rect(cornerRadius: UIConstants.Layers.cornerRadius))
                .onTapGesture {
                    if let url = store.item.appStoreURL {
                        store.send(.openURL(url))
                    }
                }
        }
    }
}
