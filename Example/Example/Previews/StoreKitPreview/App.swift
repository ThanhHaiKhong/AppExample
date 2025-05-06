//
//  StoreKitPreviewApp.swift
//  StoreKitPreview
//
//  Created by Thanh Hai Khong on 1/4/25.
//

import ComposableArchitecture
import SwiftUI

@main
struct StoreKitPreviewApp: App {
    var body: some Scene {
        WindowGroup {
            let store = Store(initialState: Subscriptions.State()) {
                Subscriptions()
            }
            StoreView(store: store)
        }
    }
}
