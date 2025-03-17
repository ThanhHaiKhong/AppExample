//
//  PhotoList.swift
//  Example
//
//  Created by Thanh Hai Khong on 15/3/25.
//

import ComposableArchitecture
import RemoteConfigClient
import PhotoLibraryClient
import PhotoPermission
import Photos
import UIKit

@Reducer
public struct PhotoList {
    @ObservableState
    public struct State: Equatable {
        public var photos: [PHAsset] = []
        public var editorChoices: [EditorChoice] = []
        public var isSelecting = false
        @Presents public var showSubscriptions: Subscriptions.State?
    }
    
    public enum Action: Equatable, BindableAction {
        case showSubscriptions(PresentationAction<Subscriptions.Action>)
        case binding(BindingAction<State>)
        case onDidLoad
        case fetchedPhotos([PHAsset])
        case fetchedEditorChoices([EditorChoice])
        case toggleSectionButtonTapped
        case premiumButtonTapped
    }
    
    @Dependency(\.remoteConfigClient) private var remoteConfigClient
    @Dependency(\.photoLibraryClient) private var photoLibraryClient
    @Dependency(\.photoPermission) private var photoPermission
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
            .ifLet(\.$showSubscriptions, action: \.showSubscriptions) {
                Subscriptions()
            }
        
        Reduce { state, action in
            switch action {
            case .onDidLoad:
                return .run { send in
                    let status = await photoPermission.authorizationStatus()
                    switch status {
                    case .authorized:
                        let assets = try await photoLibraryClient.fetchAssets()
                        await send(.fetchedPhotos(assets))
                    default:
                        break
                    }
                    
                    let editorChoices = try await remoteConfigClient.editorChoices()
                    await send(.fetchedEditorChoices(editorChoices))
                } catch: { error, send in
                    print("🔴 FETCH ASSETS ERROR on Thread: \(DispatchQueue.currentLabel) \(error)")
                }
                
            case let .fetchedEditorChoices(editorChoices):
                state.editorChoices = editorChoices
                return .none
                
            case let .fetchedPhotos(photos):
                state.photos = photos
                return .none
                
            case .toggleSectionButtonTapped:
                state.isSelecting.toggle()
                return .none
                
            case .premiumButtonTapped:
                state.showSubscriptions = Subscriptions.State()
                return .none
                
            case let .showSubscriptions(action):
                switch action {
                case .dismiss:
                    return .none
                    
                case .presented(let action):
                    return handleSubscriptionsAction(&state, action: action)
                }
                
            case .binding:
                return .none
            }
        }
    }
    
    public init() { }
}

extension PhotoList {
    private func handleSubscriptionsAction(_ state: inout State, action: Subscriptions.Action) -> Effect<Action> {
            switch action {
            case .view(let viewAction):
                return handleSubscriptionsViewAction(&state, action: viewAction)
            case .internal:
                return .none
            case .delegate:
                return .none
            default:
                return .none
            }
        }
        
        private func handleSubscriptionsViewAction(_ state: inout State, action: Subscriptions.Action.ViewAction) -> Effect<Action> {
            switch action {
            case let .interaction(interaction):
                switch interaction {
                case .dismiss:
                    state.showSubscriptions = nil
                    return .none

                default:
                    return .none
                }
                
            default:
                return .none
            }
        }
}
