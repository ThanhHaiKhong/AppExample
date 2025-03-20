//
//  PhotoCardView.swift
//  Example
//
//  Created by Thanh Hai Khong on 18/3/25.
//

import ComposableArchitecture
import SwiftUI
import Photos

struct PhotoCardView: View {
    private let store: StoreOf<PhotoCard>
    
    public init(store: StoreOf<PhotoCard>) {
        self.store = store
    }
    
    var body: some View {
        GeometryReader { proxy in
            WithPerceptionTracking {
                ZStack {
                    if let thumbnail = store.thumbnailImage {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ProgressView()
                            .task {
                                await store.send(.view(.onTask)).finish()
                            }
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .overlay(alignment: .topTrailing) {
                    Button {
                        store.send(.view(.interaction(.dismiss)))
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(.title2, design: .rounded).weight(.semibold))
                            .foregroundStyle(.red)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                }
                .contentShape(.rect)
                .clipShape(.rect)
            }
        }
    }
}
