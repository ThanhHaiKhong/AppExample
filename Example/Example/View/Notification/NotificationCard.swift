//
//  NotificationDetail.swift
//  Example
//
//  Created by Thanh Hai Khong on 10/2/25.
//

import ComposableArchitecture
import NotificationsClient
import TCAFeatureAction
import SwiftUI

@Reducer
public struct NotificationCard: Sendable {
    @ObservableState
    public struct State: Equatable {
        public let notification: NotificationItem
        
        public init(notification: NotificationItem) {
            self.notification = notification
        }
    }
    
    public enum Action: Equatable, TCAFeatureAction, BindableAction {
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(DelegateAction)
        case binding(BindingAction<State>)
        
        @CasePathable
        public enum ViewAction: Equatable {
            case onTask
            case onDisappear
            case navigation(NagivationAction)
            case interaction(UserInteraction)
            
            @CasePathable
            public enum NagivationAction: Equatable {
                
            }
            
            @CasePathable
            public enum UserInteraction: Equatable {
                
            }
        }
        
        @CasePathable
        public enum InternalAction: Equatable {
            
        }
        
        @CasePathable
        public enum DelegateAction: Equatable {
            
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
            case let .internal(internalAction):
                return handleInternalAction(state: &state, action: internalAction)
            case let .delegate(delegateAction):
                return handleDelegateAction(state: &state, action: delegateAction)
            case .binding:
                return .none
            }
        }
    }
        
    public init() { }
}

extension NotificationCard {
    
    internal func handleViewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .onTask:
            return .run(priority: .background) { send in
                
            } catch: { error, send in
                
            }
            
        default:
            return .none
        }
    }
    
    private func hanleUserInteraction(_ state: inout State, action: Action.ViewAction.UserInteraction) -> Effect<Action> {
        
    }
}

extension NotificationCard {
    
    internal func handleInternalAction(state: inout State, action: Action.InternalAction) -> Effect<Action> {
        
    }
}

extension NotificationCard {
    
    internal func handleDelegateAction(state: inout State, action: Action.DelegateAction) -> Effect<Action> {
        
    }
}
