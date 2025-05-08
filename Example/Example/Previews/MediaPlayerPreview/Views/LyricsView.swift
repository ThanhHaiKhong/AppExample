//
//  LyricsView.swift
//  Example
//
//  Created by Thanh Hai Khong on 8/5/25.
//

import UIKit
import SwiftUI
import UIKitPreviews
import UIExtensions

class LyricsView: UIView {
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupViews()
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Up Next"
		label.font = UIFont.preferredFont(forTextStyle: .headline)
		label.textColor = .label
		return label
	}()
	
	private lazy var textView: UITextView = {
		let textView = UITextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.text = "If the song has lyrics, they'll show up here when they become available"
		textView.font = UIFont.preferredFont(forTextStyle: .headline, weight: .semibold)
		textView.textColor = .label
		textView.isEditable = false
		textView.backgroundColor = .white
		textView.showsVerticalScrollIndicator = false
		return textView
	}()
}

extension LyricsView {
	
	private func setupViews() {
		backgroundColor = .white
		
		addSubview(textView)
		
		NSLayoutConstraint.activate([
			textView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
			textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
			textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
			textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
		])
	}
}
