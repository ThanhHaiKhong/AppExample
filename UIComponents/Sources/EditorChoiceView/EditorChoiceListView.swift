//
//  EditorChoiceListView.swift
//  MobilePlatform
//
//  Created by Thanh Hai Khong on 5/12/24.
//

import ComposableArchitecture
import UIConstants
import UIModifiers
import SwiftUI

@available(iOS 16.0, *)
public struct EditorChoiceListView: View {
    
    // MARK: - Properties
    
    private let store: StoreOf<EditorChoiceList>
    
    // MARK: - Init
    
    public init(store: StoreOf<EditorChoiceList>) {
        self.store = store
    }
    
    // MARK: - Body
    
    public var body: some View {
        WithPerceptionTracking {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: UIConstants.Spacing.inner) {
                    ForEach(store.scope(state: \.editorChoiceCards, action: \.editorChoiceCards)) { store in
                        EditorChoiceCardView(store: store)
                    }
                }
                .padding(.horizontal, UIConstants.Padding.horizontal)
            }
            .task {
                store.send(.onTask)
            }
        }
    }
}
