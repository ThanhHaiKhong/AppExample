//
//  SubscriptionView.swift
//  Example
//
//  Created by Thanh Hai Khong on 28/1/25.
//

import SwiftUI

struct SubscriptionView: View {
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Text("UPGRADE TO")
                        .font(.title)
                    
                    Text("PHOTO COMPRESSOR PRO")
                        .font(.title)
                        .bold()
                    
                    Text("AND UNLOCK ALL FEATURES")
                        .font(.subheadline)
                }
                
                Divider()
                
                featureRow(imageNamed: "photo.on.rectangle.angled", title: "Unlimited Compression", description: "Compression without limits")
                
                featureRow(imageNamed: "photo.fill.on.rectangle.fill", title: "Batch Compression", description: "Compress multiple photos at once")
                
                featureRow(imageNamed: "photo.on.rectangle", title: "No Ads", description: "Enjoy a clean experience")
                
                featureRow(imageNamed: "photo.fill", title: "Priority Support", description: "Get help when you need it")
            }
        }
        .background {
            GradientBackground()
        }
    }
}

extension SubscriptionView {
    @ViewBuilder
    private func featureRow(imageNamed: String, title: String, description: String) -> some View {
        HStack {
            Image(systemName: imageNamed)
                .font(.title)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
            }
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
    SubscriptionView()
}
