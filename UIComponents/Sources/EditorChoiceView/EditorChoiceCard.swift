//
//  EditorChoiceCard.swift
//  MobilePlatform
//
//  Created by Thanh Hai Khong on 4/10/24.
//

import ComposableArchitecture
import TCADependencies
import SwiftUI
import UIKit

@Reducer
public struct EditorChoiceCard {
    @ObservableState
    public struct State: Identifiable, Equatable {
        public let id: UUID = UUID()
        public let item: EditorChoice
        
        public init(item: EditorChoice) {
            self.item = item
        }
    }
    
    public enum Action: Equatable {
        case openURL(URL)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .openURL(_):
                return .none
            }
        }
    }
    
    public init() {}
    
    @MainActor
    private func openURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
