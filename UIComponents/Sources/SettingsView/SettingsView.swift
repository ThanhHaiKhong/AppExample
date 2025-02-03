//
//  SettingsView.swift
//  MobilePlatform
//
//  Created by Thanh Hai Khong on 10/10/24.
//

import ComposableArchitecture
import BlurView
import SwiftUI

@available(iOS 16.0, *)
public struct SettingsView: View {
    private let store: StoreOf<MobileSettings>
    
    public init(store: StoreOf<MobileSettings>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    SettingItemView(image: "square.and.arrow.up", title: "Share App", backgroundColor: .blue)
                        .onTapGesture {
                            store.send(.shareButtonTapped)
                        }
                    
                    SettingItemView(image: "star.fill", title: "Rate App", backgroundColor: .yellow)
                        .onTapGesture {
                            store.send(.rateButtonTapped)
                        }
                }
                .listRowBackground(BlurView(style: .systemChromeMaterial))
                
                Section {
                    SettingItemView(image: "paperplane.fill", title: "Contact the Team", subtitle: "We'd love to hear from you.", backgroundColor: .green)
                        .onTapGesture {
                            store.send(.contactButtonTapped)
                        }
                    
                    SettingItemView(image: "exclamationmark.bubble.fill", title: "Report a Problem", subtitle: "Please let us know if you encounter any issues.", backgroundColor: .black)
                        .onTapGesture {
                            store.send(.reportButtonTapped)
                        }
                    
                    SettingItemView(image: "star.bubble.fill", title: "Request a Feature", subtitle: "Don't hesitate to share your ideas with us.", backgroundColor: .red)
                        .onTapGesture {
                            store.send(.requestButtonTapped)
                        }
                }
                .listRowBackground(BlurView(style: .systemChromeMaterial))
                
                Section {
                    SettingItemView(image: "doc.richtext.fill", title: "Privacy Policy", backgroundColor: .purple)
                        .onTapGesture {
                            store.send(.privacyPolicyButtonTapped)
                        }
                    
                    SettingItemView(image: "doc.plaintext.fill", title: "Term of Use", backgroundColor: .orange)
                        .onTapGesture {
                            store.send(.termsOfServiceButtonTapped)
                        }
                }
                .listRowBackground(BlurView(style: .systemChromeMaterial))
            }
            .navigationTitle("Settings")
        }
    }
}
