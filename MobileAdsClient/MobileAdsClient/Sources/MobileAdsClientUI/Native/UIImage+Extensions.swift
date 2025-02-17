//
//  UIImage+Extensions.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 17/2/25.
//

import UIKit

public extension UIImage {
    static func fromSPM(named: String) -> UIImage? {
        return UIImage(named: named, in: Bundle.module, compatibleWith: nil)
    }
}
