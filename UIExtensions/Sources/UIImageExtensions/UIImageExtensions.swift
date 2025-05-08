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
	
	public static let tinySymbol: UIImage.SymbolConfiguration = {
		let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold, scale: .default)
		return config
	}()
	
	private func createThumbImage(diameter: CGFloat, color: UIColor) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
		return renderer.image { context in
			let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
			context.cgContext.setFillColor(color.cgColor)
			context.cgContext.fillEllipse(in: rect)
		}
	}
}
