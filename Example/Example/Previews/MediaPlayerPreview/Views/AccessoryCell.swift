//
//  AccessoryCell.swift
//  Example
//
//  Created by Thanh Hai Khong on 6/5/25.
//

import UIKit
import UIExtensions

public class AccessoryCell: UICollectionViewCell {
	
	public static let identifier = "AccessoryCell"
	
	public enum Position: Hashable {
		case left
		case right
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupViews()
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private var indicatorTrailingConstraint: NSLayoutConstraint!
	private var indicatorLeadingConstraint: NSLayoutConstraint!
	
	private lazy var minDecibelLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "-12"
		label.textColor = .redPink
		label.font = UIFont.preferredFont(forTextStyle: .subheadline)
		return label
	}()
	
	private lazy var maxDecibelLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "+12"
		label.textColor = .redPink
		label.font = UIFont.preferredFont(forTextStyle: .subheadline)
		return label
	}()
	
	private lazy var decibelTitleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Hz"
		label.textColor = .redPink
		label.font = UIFont.preferredFont(forTextStyle: .subheadline)
		return label
	}()
	
	private lazy var indicatorView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .redPink
		return view
	}()
	
	private func setupViews() {
		indicatorView.layer.cornerRadius = 2
		indicatorView.layer.masksToBounds = true
		
		contentView.backgroundColor = .systemBackground
		contentView.addSubview(maxDecibelLabel)
		contentView.addSubview(indicatorView)
		contentView.addSubview(minDecibelLabel)
		contentView.addSubview(decibelTitleLabel)
		
		indicatorTrailingConstraint = indicatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
		indicatorLeadingConstraint = indicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
		
		NSLayoutConstraint.activate([
			maxDecibelLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
			maxDecibelLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			
			indicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -18),
			indicatorView.widthAnchor.constraint(equalToConstant: 20),
			indicatorView.heightAnchor.constraint(equalToConstant: 4),
			
			minDecibelLabel.bottomAnchor.constraint(equalTo: decibelTitleLabel.topAnchor, constant: -0),
			minDecibelLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			
			decibelTitleLabel.heightAnchor.constraint(equalToConstant: 40),
			decibelTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			decibelTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
		])
		
		indicatorTrailingConstraint.isActive = true
	}
	
	public func configure(position: Position) {
		switch position {
		case .left:
			indicatorLeadingConstraint.isActive = false
			indicatorTrailingConstraint.isActive = true
			minDecibelLabel.isHidden = false
			maxDecibelLabel.isHidden = false
			decibelTitleLabel.isHidden = false
			
		case .right:
			indicatorLeadingConstraint.isActive = true
			indicatorTrailingConstraint.isActive = false
			minDecibelLabel.isHidden = true
			maxDecibelLabel.isHidden = true
			decibelTitleLabel.isHidden = true
		}
		
		contentView.layoutIfNeeded()
	}
}
