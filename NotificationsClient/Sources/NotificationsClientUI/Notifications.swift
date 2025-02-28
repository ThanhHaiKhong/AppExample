//
//  Notifications.swift
//  Example
//
//  Created by Thanh Hai Khong on 10/2/25.
//

import ComposableArchitecture
import NotificationsClient
import TCAFeatureAction
import SwiftUI

@Reducer
public struct Notifications: Sendable {
    @ObservableState
    public struct State: Equatable {
        public var notifications: [NotificationItem] = []
        
        public init() { }
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
            case fetchedNotifications([NotificationItem])
        }
        
        @CasePathable
        public enum DelegateAction: Equatable {
            
        }
    }
    
    @Dependency(\.notificationsClient) var notificationsClient
    
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

extension Notifications {
    
    internal func handleViewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .onTask:
            return .run(priority: .background) { send in
                let notifications = try await notificationsClient.getNotifications()
                await send(.internal(.fetchedNotifications(notifications)))
            } catch: { error, send in
                
            }
            
        default:
            return .none
        }
    }
    
    private func hanleUserInteraction(_ state: inout State, action: Action.ViewAction.UserInteraction) -> Effect<Action> {
        
    }
}

extension Notifications {
    
    internal func handleInternalAction(state: inout State, action: Action.InternalAction) -> Effect<Action> {
        switch action {
        case let .fetchedNotifications(notifications):
            state.notifications = notifications
            return .none
        }
    }
}

extension Notifications {
    
    internal func handleDelegateAction(state: inout State, action: Action.DelegateAction) -> Effect<Action> {
        
    }
}
