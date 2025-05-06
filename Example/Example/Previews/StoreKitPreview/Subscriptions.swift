//
//  Subscriptions.swift
//  Example
//
//  Created by Thanh Hai Khong on 1/4/25.
//

import ComposableArchitecture
import StoreKitClient
import Foundation

@Reducer
public struct Subscriptions: Sendable {
    @ObservableState
    public struct State: Equatable {
        @Presents public var alert: AlertState<Action.ViewAction.Alert>?
        public var products: [StoreKitClient.Product] = []
        public var selectedProductID: String?
        public var ui: UIState = .idle
        @Shared(.appStorage("isUserSubscribed")) public var isUserSubscribed: Bool = false
        
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
                case subcribedProduct(StoreKitClient.Transaction)
                case purchasingProduct(StoreKitClient.Transaction)
                case restoringPurchases([StoreKitClient.Transaction])
                
                public static func == (lhs: Completed, rhs: Completed) -> Bool {
                    switch (lhs, rhs) {
                        case (.subcribedProduct, .subcribedProduct),
                            (.purchasingProduct, .purchasingProduct),
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
    
    public enum Action: Equatable, BindableAction {
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
            case alert(PresentationAction<Alert>)
            
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
            
            @CasePathable
            public enum Alert: Equatable {
                case resetUIToIdle
                case renewSubscription
            }
        }
        
        @CasePathable
        public enum InternalAction: Equatable {
            case fetchedProducts([StoreKitClient.Product])
            case updateUI(State.UIState)
        }
        
        @CasePathable
        public enum DelegateAction: Equatable {
            
        }
    }
    
    @Dependency(\.storeKitClient) var storeKit
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
        .ifLet(\.$alert, action: \.view.alert)
    }
    
    public init() { }
}

extension Subscriptions {
    
    private func handleViewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
            case .onTask:
                return .run { send in
                    await withThrowingTaskGroup(of: Void.self) { group in
                        group.addTask {
                            let products = try await storeKit.loadProducts(Set(ProductConfig.Subscription.allCases.map { $0.rawValue }))
                            let sortedProducts = products.sorted { $0.price < $1.price }
                            await send(.internal(.fetchedProducts(sortedProducts)))
                        }
                    }
                }
                
            case .onDisappear:
                return .none
                
            case .navigation:
                return .none
                
            case .alert(.presented(.resetUIToIdle)):
                state.ui = .idle
                return .none
                
            case .alert(.presented(.renewSubscription)):
                return .none
                
            case .alert(.dismiss):
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
                
                if state.isUserSubscribed {
                    return .run { send in
                        /*
                         if let lastestTransaction = await iapClient.getLatestTransaction() {
                         #if DEBUG
                         print("LASTEST TRANSACTION: \(String(describing: lastestTransaction))")
                         #endif
                         await send(.internal(.updateUI(.completed(.subcribedProduct(lastestTransaction)))))
                         } else {
                         #if DEBUG
                         print("Failed to get lastest transaction")
                         #endif
                         }
                         */
                    }
                } else {
                    return .run { [productID = state.selectedProductID] send in
                        guard let productID = productID else { return }
                        let transaction = try await storeKit.purchase(productID)
                        await send(.internal(.updateUI(.completed(.purchasingProduct(transaction)))))
                    } catch: { error, send in
                        await send(.internal(.updateUI(.failed(.purchasingProduct(error)))))
                    }
                }
                
            case .restore:
                state.ui = .loading(.restoringPurchases)
                
                return .run { send in
                    let transactions = await storeKit.restorePurchases()
                    await send(.internal(.updateUI(.completed(.restoringPurchases(transactions)))))
#if DEBUG
                    print("RESTORED TRANSACTIONS: \(transactions)")
#endif
                } catch: { error, send in
                    await send(.internal(.updateUI(.failed(.restoringPurchases(error)))))
                }
                
            case .terms:
                return .run { _ in
                    if let url = URL(string: "https://orlproducts.com/terms.html") {
                        await openURL(url)
                    }
                }
                
            case .privacy:
                return .run { _ in
                    if let url = URL(string: "https://orlproducts.com/privacy.html") {
                        await openURL(url)
                    }
                }
                
            default:
                return .none
        }
    }
}

extension Subscriptions {
    
    private func handleInternalAction(state: inout State, action: Action.InternalAction) -> Effect<Action> {
        switch action {
            case let .fetchedProducts(products):
                state.products = products
                state.selectedProductID = products.first?.id
                return .none
                
            case let .updateUI(uiState):
                state.ui = uiState
                
                switch uiState {
                    case let .completed(completed):
                        switch completed {
                            case let .subcribedProduct(transaction):
                                if let expirationDate = transaction.expirationDate,
                                   let purchaseDate = transaction.purchaseDate,
                                   let displayPrice = transaction.displayPrice {
                                    let isAutoRenewable = transaction.productType == .autoRenewable
                                    let daysRemaining = calculateDaysRemaining(until: expirationDate)
                                    let subscriptionName = getSubscriptionName(from: transaction.productID)
                                    let purchaseDateString = formatDate(purchaseDate)
                                    let expirationDateString = formatDate(expirationDate)
                                    
                                    if daysRemaining > 0 {
                                        let autoRenewMessage = isAutoRenewable
                                        ? "This subscription will automatically renew unless canceled before \(expirationDateString)."
                                        : "This subscription will expire on \(expirationDateString), and you may need to renew manually."
                                        
                                        state.alert = AlertState {
                                            TextState("You're Already Subscribed")
                                        } actions: {
                                            ButtonState(role: .cancel) {
                                                TextState("OK")
                                            }
                                        } message: {
                                            TextState("""
                                You are already subscribed to \(subscriptionName) since \(purchaseDateString).
                                Your subscription is active and will expire in \(daysRemaining) days on \(expirationDateString).
                                You paid \(displayPrice) for this subscription.
                                
                                \(autoRenewMessage)
                                """)
                                        }
                                    } else if daysRemaining == 0 {
                                        let renewalSuggestion = isAutoRenewable
                                        ? "Your subscription is set to auto-renew, so there's nothing you need to do."
                                        : "Consider renewing your subscription to continue enjoying premium features."
                                        
                                        state.alert = AlertState {
                                            TextState("Subscription Expiring Today")
                                        } actions: {
                                            ButtonState(role: .cancel, action: .resetUIToIdle) {
                                                TextState("Got It!")
                                            }
                                        } message: {
                                            TextState("""
                                Your \(subscriptionName) subscription, purchased on \(purchaseDateString), is expiring today (\(expirationDateString)).
                                
                                \(renewalSuggestion)
                                """)
                                        }
                                    } else {
                                        let renewalPrompt = isAutoRenewable
                                        ? "Your subscription was canceled and has now expired. Renew it to regain access."
                                        : "Your subscription has expired. Tap 'Renew Now' to continue enjoying premium features."
                                        
                                        state.alert = AlertState {
                                            TextState("Subscription Expired")
                                        } actions: {
                                            ButtonState(role: .cancel, action: .renewSubscription) {
                                                TextState("Renew Now")
                                            }
                                        } message: {
                                            TextState("""
                                Your \(subscriptionName) subscription expired on \(expirationDateString).
                                
                                \(renewalPrompt)
                                """)
                                        }
                                    }
                                }
                                
                            case let .purchasingProduct(transaction):
                                state.$isUserSubscribed.withLock { isUserSubscribed in
                                    isUserSubscribed = true
                                }
                                
                                #if DEBUG
                                print("🛍 PURCHASED_PRODUCT: \(transaction)")
                                #endif
                                
                                if let expirationDate = transaction.expirationDate,
                                   let purchaseDate = transaction.purchaseDate,
                                   let displayPrice = transaction.displayPrice {
                                    let isAutoRenewable = transaction.productType == .autoRenewable
                                    let daysRemaining = calculateDaysRemaining(until: expirationDate)
                                    let subscriptionName = getSubscriptionName(from: transaction.productID)
                                    let purchaseDateString = formatDate(purchaseDate)
                                    let expirationDateString = formatDate(expirationDate)
                                    
                                    if daysRemaining > 0 {
                                        state.alert = AlertState {
                                            TextState("Subscription Active")
                                        } actions: {
                                            ButtonState(role: .cancel, action: .resetUIToIdle) {
                                                TextState("OK")
                                            }
                                        } message: {
                                            TextState("""
                                You are currently subscribed to \(subscriptionName) since \(purchaseDateString).
                                Your subscription will expire in \(daysRemaining) days.
                                You paid \(displayPrice) for this subscription.
                                """)
                                        }
                                    } else if daysRemaining == 0 {
                                        let renewalSuggestion = isAutoRenewable
                                        ? "Your subscription is set to auto-renew, so there's nothing you need to do."
                                        : "Consider renewing your subscription to continue enjoying premium features."
                                        
                                        state.alert = AlertState {
                                            TextState("Subscription Expiring Today")
                                        } actions: {
                                            ButtonState(role: .cancel, action: .resetUIToIdle) {
                                                TextState("Got It!")
                                            }
                                        } message: {
                                            TextState("""
                                Your \(subscriptionName) subscription, purchased on \(purchaseDateString), is expiring today (\(expirationDateString)).
                                
                                \(renewalSuggestion)
                                """)
                                        }
                                    }
                                }
                                
                            case let .restoringPurchases(transactions):
                                state.$isUserSubscribed.withLock { isUserSubscribed in
                                    isUserSubscribed = !transactions.isEmpty
                                }
                                
                                if transactions.isEmpty {
                                    state.alert = AlertState {
                                        TextState("Unable to Find Purchases to Restore")
                                    } actions: {
                                        ButtonState(role: .cancel, action: .resetUIToIdle) {
                                            TextState("Got It!")
                                        }
                                    } message: {
                                        TextState("No previous purchases found to restore, but this is the perfect time to discover something new!")
                                    }
                                } else {
                                    state.alert = AlertState {
                                        TextState("Purchases Restored")
                                    } actions: {
                                        ButtonState(role: .cancel, action: .resetUIToIdle) {
                                            TextState("Got It!")
                                        }
                                    } message: {
                                        TextState("Your previous purchases have been successfully restored!")
                                    }
                                }
                        }
                        
                        return .none
                        
                case .failed:
                        /*
                         switch failed {
                         case let .purchasingProduct(error):
                         if let subcriptionError = error as? SubscriptionError {
                         if subcriptionError != .userCancelled {
                         state.alert = AlertState {
                         TextState("Purchase Unsuccessful")
                         } actions: {
                         ButtonState(role: .cancel, action: .resetUIToIdle) {
                         TextState("OK")
                         }
                         } message: {
                         TextState("There was an error processing your purchase: \(subcriptionError.errorDescription ?? "Unknown Error")")
                         }
                         } else {
                         state.ui = .idle
                         }
                         } else {
                         state.alert = AlertState {
                         TextState("Purchase Unsuccessful")
                         } actions: {
                         ButtonState(role: .cancel, action: .resetUIToIdle) {
                         TextState("OK")
                         }
                         } message: {
                         TextState("There was an error processing your purchase: \(error.localizedDescription)")
                         }
                         }
                         
                         case let .restoringPurchases(error):
                         state.alert = AlertState {
                         TextState("Restore Unsuccessful")
                         } actions: {
                         ButtonState(role: .cancel, action: .resetUIToIdle) {
                         TextState("OK")
                         }
                         } message: {
                         TextState("\(error.localizedDescription)")
                         }
                         
                         default:
                         state.ui = .idle
                         }
                         */
                        return .none
                    default:
                        state.ui = .idle
                        return .none
                }
        }
    }
    
    private func formatPrice(_ price: Decimal?, currency: String?) -> String {
        guard let price = price, let currency = currency else { return "Unknown Price" }
        return "\(price) \(currency)"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func calculateDaysRemaining(until expirationDate: Date) -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents([.day], from: currentDate, to: expirationDate)
        return components.day ?? -1
    }
    
    private func getSubscriptionName(from productID: String) -> String {
        switch productID {
            case ProductConfig.Subscription.weekly.rawValue:
                return "Weekly Plan"
            case ProductConfig.Subscription.yearly.rawValue:
                return "Annual Plan"
            default:
                return "Your subscription"
        }
    }
}

extension Subscriptions {
    
    private func handleDelegateAction(state: inout State, action: Action.DelegateAction) -> Effect<Action> {
        
    }
}
