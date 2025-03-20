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
        public var selectedItem: Item?
        public var currentCategory: PhotoLibraryClient.Category = .all
        public var isGridLayout = true
        @Presents public var showSubscriptions: Subscriptions.State?
        @Presents public var showCard: PhotoCard.State?
        
        public struct Item: Equatable, Sendable {
            public let asset: PHAsset
            public let indexPath: IndexPath
            
            public init(asset: PHAsset, indexPath: IndexPath) {
                self.asset = asset
                self.indexPath = indexPath
            }
        }
    }
    
    public enum Action: Equatable, BindableAction {
        case showSubscriptions(PresentationAction<Subscriptions.Action>)
        case showCard(PresentationAction<PhotoCard.Action>)
        case binding(BindingAction<State>)
        case onDidLoad
        case fetchedPhotos([PHAsset])
        case fetchedEditorChoices([EditorChoice])
        case toggleSectionButtonTapped
        case premiumButtonTapped
        case didSelectedItem(State.Item)
        case didChangeCategory(PhotoLibraryClient.Category)
    }
    
    @Dependency(\.remoteConfigClient) private var remoteConfigClient
    @Dependency(\.photoLibraryClient) private var photoLibraryClient
    @Dependency(\.photoPermission) private var photoPermission
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
            .ifLet(\.$showSubscriptions, action: \.showSubscriptions) {
                Subscriptions()
            }
            .ifLet(\.$showCard, action: \.showCard) {
                PhotoCard()
            }
        
        Reduce { state, action in
            switch action {
            case .onDidLoad:
                return .run { [category = state.currentCategory] send in
                    await withThrowingTaskGroup(of: Void.self) { group in
                        group.addTask {
                            let status = await photoPermission.authorizationStatus()
                            switch status {
                            case .authorized:
                                let assets = try await photoLibraryClient.fetchAssets(category)
                                await send(.fetchedPhotos(assets))
                            default:
                                break
                            }
                        }
                        
                        group.addTask {
                            let editorChoices = try await remoteConfigClient.editorChoices()
                            await send(.fetchedEditorChoices(editorChoices))
                        }
                    }
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
                
            case let .showCard(action):
                switch action {
                case .dismiss:
                    return .none
                    
                case .presented(let action):
                    return handleCardAction(&state, action: action)
                }
                
            case let .didSelectedItem(item):
                state.selectedItem = item
                state.showCard = PhotoCard.State(asset: item.asset, thumbnailSize: PHImageManagerMaximumSize)
                return .none
                
            case let .didChangeCategory(category):
                state.currentCategory = category
                
                return .run { send in
                    let assets = try await photoLibraryClient.fetchAssets(category)
                    await send(.fetchedPhotos(assets))
                } catch: { error, send in
                    print("🔴 FETCH ASSETS ERROR on Thread: \(DispatchQueue.currentLabel) \(error)")
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

extension PhotoList {
    private func handleCardAction(_ state: inout State, action: PhotoCard.Action) -> Effect<Action> {
        switch action {
        case .view(let viewAction):
            return handleCardViewAction(&state, action: viewAction)
            
        case .internal:
            return .none
            
        case .delegate:
            return .none
        }
    }
    
    private func handleCardViewAction(_ state: inout State, action: PhotoCard.Action.ViewAction) -> Effect<Action> {
        switch action {
        case let .interaction(interaction):
            switch interaction {
            case .dismiss:
                state.selectedItem = nil
                state.showCard = nil
                
                return .none
            }
            
        default:
            return .none
        }
    }
}
