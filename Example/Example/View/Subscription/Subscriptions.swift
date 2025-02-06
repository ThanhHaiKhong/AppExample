//
//  Subscriptions.swift
//  Example
//
//  Created by Thanh Hai Khong on 4/2/25.
//

import ComposableArchitecture
import InAppPurchaseClient
import TCAFeatureAction
import AdManagerClient
import StoreKit
import SwiftUI

public struct ProductConfig {
    public enum Subscription: String, CaseIterable {
        case weekly = "com.orientpro.photocompress_Weekly"
        case yearly = "com.orientpro.photocompress_yearly"
    }

    public static var allProducts: [String] {
        return Subscription.allCases.map { $0.rawValue }
    }
}

public struct AppConfig {
    public static let sharedSecret = "bf098695f5af428cbaff6904ce073f33"
}

@Reducer
public struct Subscriptions: Sendable {
    @ObservableState
    public struct State: Equatable {
        public var products: [IAPProduct] = []
        public var selectedProductID: String?
        public var ui: UIState = .idle
        
        public init() { }
        
        public enum UIState: Equatable {
            case idle
            case loading(Loading)
            case completed(Completed)
            case failed(Failed)
            
            public enum Loading: Equatable {
                case fetchingProducts
                case purchasingProduct
                case restoringPurchases
            }
            
            public enum Completed: Equatable {
                case purchasingProduct(StoreKit.Transaction)
                case restoringPurchases([StoreKit.Transaction])
                
                public static func == (lhs: Completed, rhs: Completed) -> Bool {
                    switch (lhs, rhs) {
                    case (.purchasingProduct, .purchasingProduct),
                        (.restoringPurchases, .restoringPurchases):
                        return true
                    default:
                        return false
                    }
                }
            }
            
            public enum Failed: Equatable {
                case fetchingProducts(Error)
                case purchasingProduct(Error)
                case restoringPurchases(Error)
                
                public static func == (lhs: Failed, rhs: Failed) -> Bool {
                    switch (lhs, rhs) {
                    case (.fetchingProducts, .fetchingProducts),
                        (.purchasingProduct, .purchasingProduct),
                        (.restoringPurchases, .restoringPurchases):
                        return true
                    default:
                        return false
                    }
                }
            }
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
                case dismiss
                case subscribe
                case terms
                case privacy
                case restore
                case selectProduct(String)
            }
        }
        
        @CasePathable
        public enum InternalAction: Equatable {
            case fetchedProducts([IAPProduct])
            case updateUI(State.UIState)
        }
        
        @CasePathable
        public enum DelegateAction: Equatable {
            
        }
    }
    
    @Dependency(\.inAppPurchaseClient) var iapClient
    @Dependency(\.openURL) var openURL
    
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

extension Subscriptions {
    
    internal func handleViewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .onTask:
            return .run { send in
                let products = try await iapClient.fetchProducts(ProductConfig.allProducts)
                let sortedProducts = products.sorted { $0.price < $1.price }
                await send(.internal(.fetchedProducts(sortedProducts)))
                
                let verifyReceipt = try await iapClient.verifySubscriptionStatus(ProductConfig.allProducts, AppConfig.sharedSecret)
                print("VERIFY RECEIPT: \(verifyReceipt)")
            }
            
        case .onDisappear:
            return .none
            
        case .navigation:
            return .none
            
        case let .interaction(action):
            return hanleUserInteraction(&state, action: action)
        }
    }
    
    private func hanleUserInteraction(_ state: inout State, action: Action.ViewAction.UserInteraction) -> Effect<Action> {
        switch action {
        case let .selectProduct(productID):
            state.selectedProductID = productID
            return .none
            
        case .subscribe:
            state.ui = .loading(.purchasingProduct)
            return .run { [productID = state.selectedProductID] send in
                guard let productID = productID else { return }
                let transaction = try await iapClient.purchase(productID)
                await send(.internal(.updateUI(.completed(.purchasingProduct(transaction)))))
            } catch: { error, send in
                await send(.internal(.updateUI(.failed(.purchasingProduct(error)))))
            }
            
        case .restore:
            let appOpen: AdManagerClient.AdType = .appOpen("ca-app-pub-3940256099942544/5575463023")
            let interstitial: AdManagerClient.AdType = .interstitial("ca-app-pub-3940256099942544/4411468910")
            let rewarded: AdManagerClient.AdType = .rewarded("ca-app-pub-3940256099942544/1712485313")
            let rules: [AdManagerClient.AdRule] = []
            
            return .runWithAdCheck(adType: interstitial) { send in

            }
            
        case .terms:
            return .run { _ in
                if let url = URL(string: "https://orlincproducts.wixsite.com/compressphotos/termsofservice") {
                    await openURL(url)
                }
            }
            
        case .privacy:
            return .run { _ in
                if let url = URL(string: "https://orlincproducts.wixsite.com/toonaicartoonphoto/privacypolicy") {
                    await openURL(url)
                }
            }
            
        default:
            return .none
        }
    }
}

extension Subscriptions {
    
    internal func handleInternalAction(state: inout State, action: Action.InternalAction) -> Effect<Action> {
        switch action {
        case let .fetchedProducts(products):
            state.products = products
            state.selectedProductID = products.first?.id
            return .none
            
        case let .updateUI(uiState):
            state.ui = uiState
            return .none
        }
    }
}

extension Subscriptions {
    
    internal func handleDelegateAction(state: inout State, action: Action.DelegateAction) -> Effect<Action> {
        
    }
}
