//
//  Models.swift
//  PhotosClient
//
//  Created by Thanh Hai Khong on 1/4/25.
//

import PHAssetExtensions
import Foundation
import UIKit
import Photos

extension PhotosClient {
    public enum Category: String, Identifiable, Equatable, CaseIterable, Sendable {
        case all = "All Photos"
        case favorite = "Favorites"
        case recent = "Recents"
        case burst = "Burst Photos"
        case live = "Live Photos"
        case screenShot = "Screenshots"
        
        public var id: String { rawValue }
        
        public var systemName: String {
            switch self {
                case .all: return "photo.stack.fill"
                case .favorite: return "star.fill"
                case .recent: return "clock.fill"
                case .burst: return "square.stack.3d.forward.dottedline"
                case .live: return "livephoto"
                case .screenShot: return "camera.viewfinder"
            }
        }
        
        public var activeColor: UIColor {
            switch self {
                case .all: return .systemIndigo
                case .favorite: return .systemYellow
                case .recent: return .systemGreen
                case .burst: return .systemRed
                case .live: return .systemBlue
                case .screenShot: return .systemOrange
            }
        }
        
        public var fetchOptions: PHFetchOptions {
            switch self {
                case .all: return .all
                case .favorite: return .favorite
                case .recent: return .recent
                case .burst: return .burst
                case .live: return .live
                case .screenShot: return .screenshot
            }
        }
    }
}
