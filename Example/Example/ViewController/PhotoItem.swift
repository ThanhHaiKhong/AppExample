//
//  PhotoItem.swift
//  Example
//
//  Created by Thanh Hai Khong on 15/3/25.
//

import ComposableArchitecture
import Photos
import UIKit

@Reducer
public struct PhotoItem {
    @ObservableState
    public struct State: Identifiable, Equatable {
        public let id: String
        public let thumbnailImage: UIImage?
        
        public init(id: String, thumbnailImage: UIImage? = nil) {
            self.id = id
            self.thumbnailImage = thumbnailImage
        }
    }
    
    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            }
        }
    }
        
    public init() { }
}
