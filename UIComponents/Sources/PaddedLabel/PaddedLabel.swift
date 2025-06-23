//
//  PaddedLabel.swift
//  UIComponents
//
//  Created by Thanh Hai Khong on 23/6/25.
//

import UIKit

public class PaddedLabel: UILabel {
	private var padding: UIEdgeInsets
	
	public init(padding: UIEdgeInsets = .zero) {
		self.padding = padding
		super.init(frame: .zero)
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.padding = .zero
		super.init(coder: aDecoder)
	}
	
	public override func drawText(in rect: CGRect) {
		if let text = self.text, !text.isEmpty {
			let insetRect = rect.inset(by: padding)
			super.drawText(in: insetRect)
		} else {
			super.drawText(in: rect)
		}
	}
	
	public override var intrinsicContentSize: CGSize {
		if let text = self.text, !text.isEmpty {
			let size = super.intrinsicContentSize
			return CGSize(width: size.width + padding.left + padding.right,
						  height: size.height + padding.top + padding.bottom)
		} else {
			return super.intrinsicContentSize
		}
	}
}
