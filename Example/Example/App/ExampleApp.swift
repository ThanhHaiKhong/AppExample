//
//  ExampleApp.swift
//  Example
//
//  Created by Thanh Hai Khong on 15/11/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            SubscriptionView(store: Store(
                initialState: Subscriptions.State()) {
                    Subscriptions()
                }
            )
        }
    }
}
