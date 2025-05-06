//
//  ProductConfig.swift
//  Example
//
//  Created by Thanh Hai Khong on 1/4/25.
//

import Foundation

public struct ProductConfig {
    public enum Subscription: String, CaseIterable {
        case weekly = "com.orientpro.photocompress_Weekly"
        case yearly = "com.orientpro.photocompress_yearly"
    }
    
    public static var allProducts: [String] {
        return Subscription.allCases.map { $0.rawValue }
    }
}

public struct AppConfig {
    public static let sharedSecret = "bf098695f5af428cbaff6904ce073f33"
    public static let appID = "1615572010"
    public static var appName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Compress Photo"
    }
    public static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    public static var appBuild: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    public static var supportEmail: String {
        return "info@orlproducts.com"
    }
}
