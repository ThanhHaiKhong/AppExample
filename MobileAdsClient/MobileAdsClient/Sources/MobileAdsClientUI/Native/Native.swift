//
//  File.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 6/2/25.
//

@preconcurrency import GoogleMobileAds
import ComposableArchitecture
import TCAInitializableReducer
import NativeAdClient

@Reducer
public struct Native: TCAInitializableReducer, Sendable {
    @ObservableState
    public struct State: Identifiable, Sendable, Equatable {
        public var id : String = UUID().uuidString
        public let adUnitID: String
        public var nativeAd: NativeAd?
        public var adHeight: CGFloat = 300.0
        
        public init(adUnitID: String) {
            self.adUnitID = adUnitID
        }
    }
    
    public enum Action: Equatable, BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case receivedNativeAd(NativeAd)
        case updateAdHeight(CGFloat)
    }
    
    @Dependency(\.nativeAdClient) var nativeAdClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run(priority: .background) { [adUnitID = state.adUnitID] send in
                    var rootViewController: UIViewController? = nil
                    if let scene = await UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootVC = await scene.windows.first?.rootViewController {
                        rootViewController = rootVC
                    }
                    let nativeAd = try await nativeAdClient.loadAd(adUnitID, rootViewController)
                    await send(.receivedNativeAd(nativeAd), animation: .default)
                } catch: { error, send in
                    print("Error loading native ad: \(error.localizedDescription)")
                }
                
            case let .receivedNativeAd(nativeAd):
                state.nativeAd = nativeAd
                return .none
                
            case let .updateAdHeight(height):
                state.adHeight = height
                return .none
                
                default:
                    return .none
            }
        }
    }
        
    public init() { }
}

