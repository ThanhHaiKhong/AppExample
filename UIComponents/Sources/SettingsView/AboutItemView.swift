//
//  AboutItemView.swift
//  MobilePlatform
//
//  Created by Thanh Hai Khong on 10/10/24.
//

import SwiftUI

@available(iOS 16.0, *)
public struct AboutItemView: View {
    
    let appIcon: UIImage?
    
    public var body: some View {
        HStack {
            if let appIcon {
                Image(uiImage: appIcon)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            
            VStack(alignment: .leading) {
                Text("\(appName), Version \(appVersion)")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentColor)
                
                Text("_Copyright © \(currentYear) \("ORIENTPRO")\nAll rights reserved._")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
    
    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    private var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}
