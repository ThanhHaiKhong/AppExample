//
//  SettingItemView.swift
//  MobilePlatform
//
//  Created by Thanh Hai Khong on 10/10/24.
//

import SwiftUI

@available(iOS 16.0, *)
public struct SettingItemView: View {
    
    public let image: String
    public let title: String
    public let subtitle: String?
    public let backgroundColor: Color
    
    init(image: String, title: String, subtitle: String? = nil, backgroundColor: Color = .blue) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .font(.system(.subheadline, design: .default).weight(.medium))
                .padding(8)
                .frame(width: 40, height: 40)
                .foregroundColor(backgroundColor)
                .background(backgroundColor.opacity(0.25))
                .clipShape(.rect(cornerRadius: 10, style: .continuous))
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(.headline, design: .default).weight(.medium))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(.subheadline, design: .default).weight(.regular))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .contentShape(Rectangle())
    }
}
