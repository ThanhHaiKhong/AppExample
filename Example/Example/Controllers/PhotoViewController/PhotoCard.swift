//
//  PhotoCard.swift
//  Example
//
//  Created by Thanh Hai Khong on 15/3/25.
//

import ComposableArchitecture
import TCAFeatureAction
import PhotosClient
import Photos
import UIKit

@Reducer
public struct PhotoCard: Sendable {
    @ObservableState
    public struct State: Identifiable, Equatable {
        public var id: String
        public var asset: PHAsset
        public var thumbnailImage: UIImage?
        public var thumbnailSize: CGSize = CGSizeMake(128, 128)
        public var fileName: String?
        public var fileSize: Int64?
        
        public var isSelecting: Bool = false
        public var isSelected: Bool  = false
        
        public init(
            asset: PHAsset,
            thumbnailSize: CGSize = CGSizeMake(128, 128)
        ) {
            self.id = asset.localIdentifier
            self.asset = asset
            self.thumbnailSize = thumbnailSize
        }
    }
    
    public enum Action: Equatable, TCAFeatureAction {
        @CasePathable
        public enum ViewAction: Equatable {
            case onTask
            case navigation(NagivationAction)
            case interaction(UserInteraction)
            
            @CasePathable
            public enum NagivationAction: Equatable {
                
            }
            
            @CasePathable
            public enum UserInteraction: Equatable {
                case dismiss
            }
        }
        
        @CasePathable
        public enum InternalAction: Equatable {
            case fetchedThumbnailImage(UIImage)
            case fetchedName(String)
            case fetchedFileSize(Int64)
        }
        
        @CasePathable
        public enum DelegateAction: Equatable {
            
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(DelegateAction)
    }
    
    @Dependency(\.photosClient) var photosClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
            case let .internal(internalAction):
                return handleInternalAction(state: &state, action: internalAction)
                
            case let .delegate(delegateAction):
                return handleDelegateAction(state: &state, action: delegateAction)
            }
        }
    }
    
    public init() {}
}

// MARK: - Handle Methods

extension PhotoCard {
    private func handleViewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .onTask:
            return .run { [localID = state.id, thumbnailSize = state.thumbnailSize] send in
                await withTaskGroup(of: Void.self) { group in
                    /*
                    if let thumbnail = await photoFetcher.artworkImage(localID, thumbnailSize) {
                        group.addTask {
                            await send(.internal(.fetchedThumbnailImage(thumbnail)), animation: .easeInOut)
                        }
                    }
                    
                    if let name = await photoFetcher.fileName(localID) {
                        group.addTask {
                            await send(.internal(.fetchedName(name)))
                        }
                    }
                    
                    if let size = await photoFetcher.fileSize(localID) {
                        group.addTask {
                            await send(.internal(.fetchedFileSize(size)))
                        }
                    }
                    */
                }
            } catch: { error, send in
                print("FETCHING PHAsset INFO ERROR: \(error.localizedDescription)")
            }
            
        default:
            return .none
        }
    }
    
    private func handleInternalAction(state: inout State, action: Action.InternalAction) -> Effect<Action> {
        switch action {
        case let .fetchedThumbnailImage(artwork):
            state.thumbnailImage = artwork
            return .none
            
        case let .fetchedName(name):
            state.fileName = name
            return .none
        
        case let .fetchedFileSize(fileSize):
            state.fileSize = fileSize
            return .none
        }
    }
    
    private func handleDelegateAction(state: inout State, action: Action.DelegateAction) -> Effect<Action> {
        
    }
}
