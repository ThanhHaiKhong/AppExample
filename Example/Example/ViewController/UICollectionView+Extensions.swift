//
//  UICollectionView+Extensions.swift
//  Example
//
//  Created by Thanh Hai Khong on 12/3/25.
//

import UIKit

extension UICollectionView {
    
    public func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        if let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect) {
            return allLayoutAttributes.map { $0.indexPath }
        }
        return []
    }
}
