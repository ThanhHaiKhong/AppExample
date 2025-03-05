//
//  EditorChoiceList.swift
//  MobilePlatform
//
//  Created by Thanh Hai Khong on 5/12/24.
//

import ComposableArchitecture
import RemoteConfigClient
import Foundation

@Reducer
public struct EditorChoiceList: Sendable {
    
    @ObservableState
    public struct State: Equatable, Sendable {
        public var editorChoiceCards: IdentifiedArrayOf<EditorChoiceCard.State> = []
        
        public init() {}
    }
     
    public enum Action: Equatable, Sendable {
        case onTask
        case editorChoiceCards(IdentifiedActionOf<EditorChoiceCard>)
        case editorChoiceCardsResponse([EditorChoice])
    }
    
    @Dependency(\.remoteConfigClient) private var remoteConfigClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onTask:
                return .run { send in
                    let editorChoices = try await remoteConfigClient.editorChoices()
                    await send(.editorChoiceCardsResponse(editorChoices), animation: .default)
                }
            
            case .editorChoiceCards(_):
                return .none
                
            case let .editorChoiceCardsResponse(choices):
                let editorChoices = choices.map { EditorChoiceCard.State(item: $0) }
                state.editorChoiceCards = IdentifiedArrayOf(uniqueElements: editorChoices)
                return .none
            }
        }
    }
    
    public init() {
        
    }
}
