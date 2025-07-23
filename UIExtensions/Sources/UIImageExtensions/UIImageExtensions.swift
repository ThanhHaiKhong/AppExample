//
//  UIImageExtensions.swift
//  UIExtensions
//
//  Created by Thanh Hai Khong on 29/4/25.
//

import UIKit

extension UIImage.SymbolConfiguration {
    
    public static let largeSymbol: UIImage.SymbolConfiguration = {
        let config = UIImage.SymbolConfiguration(pointSize: 54, weight: .bold, scale: .default)
        return config
    }()
	
	public static let mediumLargeSymbol: UIImage.SymbolConfiguration = {
		let config = UIImage.SymbolConfiguration(pointSize: 44, weight: .bold, scale: .default)
		return config
	}()
    
	public static let mediumSymbol: UIImage.SymbolConfiguration = {
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .semibold, scale: .default)
        return config
    }()
	
	public static let smallMediumSymbol: UIImage.SymbolConfiguration = {
		let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold, scale: .default)
		return config
	}()
    
	public static let smallSymbol: UIImage.SymbolConfiguration = {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold, scale: .default)
        return config
    }()
	
	public static let tinySmallSymbol: UIImage.SymbolConfiguration = {
		let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold, scale: .default)
		return config
	}()
	
	public static let tinySymbol: UIImage.SymbolConfiguration = {
		let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold, scale: .default)
		return config
	}()
}

extension UIImage {
	
	public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
		let rect = CGRect(origin: .zero, size: size)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.setFill()
		UIRectFill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		guard let cgImage = image?.cgImage else { return nil }
		self.init(cgImage: cgImage)
	}
	
	public func createThumbImage(diameter: CGFloat, color: UIColor) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
		return renderer.image { context in
			let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
			context.cgContext.setFillColor(color.cgColor)
			context.cgContext.fillEllipse(in: rect)
		}
	}
	
	public static func imageWithSystemSymbol(
		name: String,
		symbolColor: UIColor = .white,
		backgroundColor: UIColor = .systemBlue,
		size: CGSize = CGSize(width: 40, height: 40),
		cornerRadius: CGFloat = 10
	) -> UIImage? {
		let config = UIImage.SymbolConfiguration(pointSize: size.height * 0.5, weight: .medium)
		guard let symbol = UIImage(systemName: name, withConfiguration: config) else {
			return nil
		}
		
		let renderer = UIGraphicsImageRenderer(size: size)
		return renderer.image { context in
			let rect = CGRect(origin: .zero, size: size)
			
			// Draw background
			let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
			backgroundColor.setFill()
			path.fill()
			
			// Draw symbol (centered)
			let symbolSize = symbol.size
			let symbolOrigin = CGPoint(
				x: (size.width - symbolSize.width) / 2,
				y: (size.height - symbolSize.height) / 2
			)
			symbol.withTintColor(symbolColor, renderingMode: .alwaysOriginal)
				.draw(at: symbolOrigin)
		}
	}
}

extension UIImage {
	public func resize(to size: CGSize) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(size, false, scale)
		draw(in: CGRect(origin: .zero, size: size))
		let result = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return result ?? self
	}
}
