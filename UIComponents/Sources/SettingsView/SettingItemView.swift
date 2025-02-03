//
//  SettingItemView.swift
//  MobilePlatform
//
//  Created by Thanh Hai Khong on 10/10/24.
//

import SwiftUI

@available(iOS 16.0, *)
public struct SettingItemView: View {
    
    // MARK: - Public Properties
    
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
    
    // MARK: - Body
    
    public var body: some View {
        HStack(spacing: 14) {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .padding(7)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 5))
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(.headline, design: .rounded).weight(.medium))
                    .fontWeight(.regular)
                    .lineLimit(1)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(.footnote, design: .rounded).weight(.regular))
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .contentShape(Rectangle())
    }
}
