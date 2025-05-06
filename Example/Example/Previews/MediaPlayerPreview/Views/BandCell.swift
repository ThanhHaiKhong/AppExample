//
//  BandCell.swift
//  Example
//
//  Created by Thanh Hai Khong on 5/5/25.
//

import UIKit
import SwiftUI
import UIKitPreviews

public protocol BandCellDelegate: AnyObject {
	func didChangeValue(value: Float, index: Int)
}

public class BandCell: UICollectionViewCell {
	public static let identifier = "BandCell"
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupViews()
	}
	
	public weak var delegate: BandCellDelegate?
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "500"
		label.font = UIFont.preferredFont(forTextStyle: .footnote)
		label.textAlignment = .center
		label.textColor = .blueBerry
		return label
	}()
	
	public lazy var slider: UISlider = {
		let slider = UISlider()
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.minimumValue = -12.0
		slider.maximumValue = 12.0
		slider.tintColor = .redPink
		slider.minimumTrackTintColor = .redPink
		slider.maximumTrackTintColor = .blueBerry
		slider.value = 0
		slider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
		slider.setThumbImage(UIImage(named: "icon_dot"), for: .normal)
		slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
		return slider
	}()
	
	private func setupViews() {
		contentView.backgroundColor = .systemBackground
		contentView.addSubview(slider)
		contentView.addSubview(titleLabel)
		
		NSLayoutConstraint.activate([
			slider.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			slider.topAnchor.constraint(equalTo: contentView.topAnchor, constant: (bounds.height - 55) / 2),
			slider.widthAnchor.constraint(equalTo: contentView.heightAnchor, constant: -50),
			
			titleLabel.heightAnchor.constraint(equalToConstant: 40),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
	
	public func configureCell(_ value: Float) {
		slider.setValue(value, animated: true)
	}
	
	// MARK: - Actions
	
	@objc func sliderValueChanged(_ sender: UISlider) {
		delegate?.didChangeValue(value: sender.value, index: sender.tag)
	}
}
