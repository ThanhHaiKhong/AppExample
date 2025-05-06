// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

extension UIFont {
	public static func preferredFont(forTextStyle style: UIFont.TextStyle, weight: UIFont.Weight = .regular, design: UIFontDescriptor.SystemDesign? = nil) -> UIFont {
		var descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
		if let design, let designDescriptor = descriptor.withDesign(design) {
			descriptor = designDescriptor
		}
		let fontSize = descriptor.pointSize
		return UIFont.systemFont(ofSize: fontSize, weight: weight)
	}
}

extension UIColor {
	public convenience init?(hex: String) {
		var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		
		// Xoá dấu "#" nếu có
		if hexSanitized.hasPrefix("#") {
			hexSanitized.removeFirst()
		}
		
		var rgb: UInt64 = 0
		let length = hexSanitized.count
		
		guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
		
		var r, g, b, a: CGFloat
		
		switch length {
		case 6: // RRGGBB
			r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
			g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
			b = CGFloat(rgb & 0x0000FF) / 255.0
			a = 1.0
		case 8: // RRGGBBAA
			r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
			g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
			b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
			a = CGFloat(rgb & 0x000000FF) / 255.0
		default:
			return nil
		}
		
		self.init(red: r, green: g, blue: b, alpha: a)
	}
}

extension UIColor {
	public class var redPink: UIColor {
		return UIColor(hex: "fd2959") ?? .red
	}
	
	public class var blueBerry: UIColor {
		return UIColor(red: 72.0 / 255.0, green: 68.0 / 255.0, blue: 145.0 / 255.0, alpha: 1.0)
	}
}
