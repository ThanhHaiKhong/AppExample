//
//  func.swift
//  Example
//
//  Created by Thanh Hai Khong on 12/3/25.
//

import UIKit

extension UIFont {
    public class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return systemFont
    }

    public class func preferredRoundedFont(forTextStyle style: UIFont.TextStyle, weight: UIFont.Weight = .regular) -> UIFont {
        let systemFont = UIFont.preferredFont(forTextStyle: style)
        let size = systemFont.pointSize
        
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        if let descriptor = font.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return font
    }
}
