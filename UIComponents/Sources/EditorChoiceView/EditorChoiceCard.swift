//
//  EditorChoiceCard.swift
//  MobilePlatform
//
//  Created by Thanh Hai Khong on 4/10/24.
//

import ComposableArchitecture
import RemoteConfigClient
import Foundation

@Reducer
public struct EditorChoiceCard: Sendable {
    @ObservableState
    public struct State: Identifiable, Equatable, Sendable {
        public let id: UUID = UUID()
        public let item: EditorChoice
        
        public init(item: EditorChoice) {
            self.item = item
        }
    }
    
    public enum Action: Equatable, Sendable {
        case openURL(URL)
    }
    
    @Dependency(\.openURL) var openURL
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case let .openURL(url):
                return .run { send in
                    await openURL(url)
                }
            }
        }
    }
    
    public init() {}
}
