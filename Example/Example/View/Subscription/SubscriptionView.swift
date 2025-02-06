//
//  SubscriptionView.swift
//  Example
//
//  Created by Thanh Hai Khong on 28/1/25.
//

import ComposableArchitecture
import InAppPurchaseClient
import SwiftUI

struct SubscriptionView: View {
    
    @Perception.Bindable var store: StoreOf<Subscriptions>
    
    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack {
                    VStack(spacing: 8) {
                        Text("UPGRADE TO")
                            .font(.system(.headline, design: .default).weight(.semibold))
                        
                        Text("PHOTO COMPRESSOR PRO")
                            .font(.system(.title2, design: .default).weight(.black))
                            .foregroundStyle(.green)
                        
                        Text("AND UNLOCK ALL FEATURES")
                            .font(.system(.headline, design: .default).weight(.semibold))
                    }
                    
                    Divider()
                        .padding(.vertical, 20)
                        .overlay {
                            HStack {
                                ForEach(0..<5) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(.headline, design: .default).weight(.bold))
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        featureRow(imageNamed: "rectangle.compress.vertical", title: "Unlimited Compression", description: "Compression without limits and watermarks on all photos and videos in your library", foregroundColor: .blue)
                        
                        featureRow(imageNamed: "photo.fill.on.rectangle.fill", title: "Batch Compression", description: "Compress multiple photos at once with batch processing mode and save time", foregroundColor: .green)
                        
                        featureRow(imageNamed: "headset", title: "Priority Support", description: "Get help when you need it with priority support from our team of experts", foregroundColor: .red)
                        
                        featureRow(imageNamed: "envelope.fill", title: "New Features", description: "Access to all upcoming features and improvements before anyone else with early access", foregroundColor: .orange)
                        
                        featureRow(imageNamed: "tag.slash.fill", title: "No Ads, Cancel Anytime", description: "Enjoy a clean experience without any ads or popups in the app or on the website", foregroundColor: .purple)
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .padding(.vertical, 20)
                        .overlay {
                            HStack {
                                ForEach(0..<5) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(.headline, design: .default).weight(.bold))
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                }
                .safeAreaInset(edge: .top, spacing: 20) {
                    EmptyView()
                }
                .safeAreaInset(edge: .bottom, spacing: 230) {
                    EmptyView()
                }
            }
            .background {
                GradientBackground()
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    store.send(.view(.interaction(.dismiss)))
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(.title2, design: .rounded).weight(.semibold))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
            }
            .overlay(alignment: .bottom) {
                footerView()
            }
            .onAppear {
                store.send(.view(.onTask))
            }
        }
    }
}

extension SubscriptionView {
    @ViewBuilder
    private func featureRow(imageNamed: String, title: String, description: String, foregroundColor: Color = .red) -> some View {
        HStack(spacing: 16) {
            Image(systemName: imageNamed)
                .resizable()
                .scaledToFit()
                .font(.system(.subheadline, design: .default).weight(.semibold))
                .padding(8)
                .frame(width: 40, height: 40)
                .foregroundColor(foregroundColor)
                .background(foregroundColor.opacity(0.25))
                .clipShape(.rect(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(.headline, design: .default).weight(.semibold))
                
                Text(description)
                    .font(.system(.subheadline, design: .default).weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func productItem(_ product: IAPProduct) -> some View {
        VStack {
            VStack(spacing: 8) {
                Text(product.displayPrice)
                    .font(.system(.headline, design: .default).weight(.bold))
                
                Text(product.localizedDescription)
                    .font(.system(.headline, design: .default).weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(.thinMaterial)
            .clipShape(.rect(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(store.selectedProductID == product.id ? .yellow : .secondary, lineWidth: 2.5)
            }
            
            Text(product.offer)
                .font(.system(.subheadline, design: .default).weight(.semibold))
                .foregroundStyle(store.selectedProductID == product.id ? .pink : .secondary)
        }
        .onTapGesture {
            store.send(.view(.interaction(.selectProduct(product.id))), animation: .default)
        }
    }
    
    @ViewBuilder
    private func footerView() -> some View {
        WithPerceptionTracking {
            VStack(spacing: 12) {
                HStack(spacing: 60) {
                    ForEach(Array(store.products.enumerated()), id: \.element) { index, product in
                        productItem(product)
                    }
                }
                .overlay {
                    Text("OR")
                        .font(.system(.subheadline, design: .default).weight(.bold))
                        .offset(y: -15)
                }
                
                Button {
                    store.send(.view(.interaction(.subscribe)))
                } label: {
                    if store.ui == .loading(.purchasingProduct) {
                        ProgressView()
                    } else {
                        Text("SUBSCRIBE")
                    }
                }
                .font(.system(.headline, design: .default).weight(.bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.yellow)
                .clipShape(.rect(cornerRadius: 10, style: .continuous))
                .padding(.vertical, 8)
                
                HStack {
                    Button {
                        store.send(.view(.interaction(.terms)))
                    } label: {
                        Text("Terms")
                    }
                    
                    Spacer()
                    
                    Button {
                        store.send(.view(.interaction(.restore)))
                    } label: {
                        Text("Restore")
                    }
                    
                    Spacer()
                    
                    Button {
                        store.send(.view(.interaction(.privacy)))
                    } label: {
                        Text("Policy")
                    }
                }
                .font(.system(.headline, design: .default).weight(.semibold))
                .foregroundStyle(.blue)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
        }
    }
}

struct GradientBackground: View {
    var body: some View {
        LinearGradient(colors: [.cyan.opacity(0.5), .orange.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

#Preview {
    SubscriptionView(store: Store(
        initialState: Subscriptions.State()) {
            Subscriptions()
        }
    )
}
