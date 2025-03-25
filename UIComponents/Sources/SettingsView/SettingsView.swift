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
public struct SettingsView<Background>: View where Background: View {
    private let store: StoreOf<MobileSettings>
    private var background: () -> Background
    private let rowInsets: EdgeInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
    
    public init(
        store: StoreOf<MobileSettings>,
        @ViewBuilder background: @escaping () -> Background
    ) {
        self.store = store
        self.background = background
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    SettingItemView(image: "sharedwithyou", title: "Share with Friends", subtitle: "Let your friends know about our app.", backgroundColor: .blue)
                        .onTapGesture {
                            store.send(.shareButtonTapped)
                        }
                    
                    SettingItemView(image: "star.fill", title: "Rate & Review", subtitle: "Give us your feedback on the App Store.", backgroundColor: .yellow)
                        .onTapGesture {
                            store.send(.rateButtonTapped)
                        }
                }
                .listRowBackground(BlurView(style: .systemThinMaterial))
                .listRowInsets(rowInsets)
                
                Section(header: Text("Need help or have suggestions?"),
                        footer: Text("We appreciate your input in making our app better!")) {
                    SettingItemView(image: "paperplane.fill", title: "Get in Touch", subtitle: "Have questions or suggestions? Reach out to us.", backgroundColor: .green)
                        .onTapGesture {
                            store.send(.contactButtonTapped)
                        }
                    
                    SettingItemView(image: "exclamationmark.bubble.fill", title: "Report an Issue", subtitle: "Encountered an issue? Let us know so we can fix it.", backgroundColor: .pink)
                        .onTapGesture {
                            store.send(.reportButtonTapped)
                        }
                    
                    SettingItemView(image: "star.bubble.fill", title: "Suggest a Feature", subtitle: "Share your ideas to help us improve the app.", backgroundColor: .cyan)
                        .onTapGesture {
                            store.send(.requestButtonTapped)
                        }
                }
                .listRowBackground(BlurView(style: .systemThinMaterial))
                .listRowInsets(rowInsets)
                
                Section {
                    SettingItemView(image: "doc.richtext.fill", title: "Our Privacy Policy", subtitle: "Learn how we handle your data and privacy.", backgroundColor: .indigo)
                        .onTapGesture {
                            store.send(.privacyPolicyButtonTapped)
                        }
                    
                    SettingItemView(image: "doc.plaintext.fill", title: "Terms & Conditions", subtitle: "Understand the rules and guidelines for using our app.", backgroundColor: .mint)
                        .onTapGesture {
                            store.send(.termsOfServiceButtonTapped)
                        }
                }
                .listRowBackground(BlurView(style: .systemThinMaterial))
                .listRowInsets(rowInsets)
            }
            .scrollContentBackground(.hidden)
            .background {
                background()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.dismissButtonTapped)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(.headline, design: .rounded).weight(.semibold))
                    }
                }
            }
        }
    }
}

@available(iOS 16.0, *)
extension SettingsView where Background == EmptyView {
    public init(store: StoreOf<MobileSettings>) {
        self.init(store: store, background: { EmptyView() })
    }
}

/*
 1️⃣ Chia sẻ và Đánh giá
 •    Header: "Spread the word & show your support!"
 •    Footer: "Your feedback and recommendations help us grow."
 
 2️⃣ Hỗ trợ và Góp ý
 •    Header: "Need help or have suggestions?"
 •    Footer: "We appreciate your input in making our app better!"
 
 3️⃣ Chính sách & Điều khoản
 •    Header: "Understand how we protect your data and rights."
 •    Footer: "Please review these documents carefully to stay informed."
 */
