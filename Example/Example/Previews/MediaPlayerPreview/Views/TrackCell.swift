//
//  TrackCell.swift
//  Example
//
//  Created by Thanh Hai Khong on 7/5/25.
//

import SwiftUI
import UIKit
import Kingfisher
import UIKitPreviews
import UIExtensions

public class TrackCell: UICollectionViewListCell {
	
	public static let identifier = "TrackCell"
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupViews()
	}
	
	public weak var delegate: BandCellDelegate?
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.image = UIImage(named: "sample_artwork")
		imageView.layer.cornerRadius = 5
		imageView.layer.masksToBounds = true
		return imageView
	}()
	
	public lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "You belong with me"
		label.font = UIFont.preferredFont(forTextStyle: .headline)
		label.textColor = .label
		return label
	}()
	
	public lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Taylor Swift"
		label.font = UIFont.preferredFont(forTextStyle: .subheadline)
		label.textColor = .secondaryLabel
		return label
	}()
	
	public lazy var moreButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
		
		var configuration = UIButton.Configuration.plain()
		configuration.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration.smallSymbol)
		configuration.baseForegroundColor = .label
		configuration.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
		
		button.configuration = configuration
		button.addTarget(self, action: #selector(moreButtonTapped(_:)), for: .touchUpInside)
		return button
	}()
	
	private func setupViews() {
		contentView.backgroundColor = .white
		
		let titleStackView: UIStackView = {
			let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
			stackView.translatesAutoresizingMaskIntoConstraints = false
			stackView.axis = .vertical
			stackView.spacing = 4
			return stackView
		}()
		
		let stackView: UIStackView = {
			let stackView = UIStackView(arrangedSubviews: [imageView, titleStackView])
			stackView.translatesAutoresizingMaskIntoConstraints = false
			stackView.axis = .horizontal
			stackView.spacing = 12
			stackView.distribution = .fill
			stackView.alignment = .leading
			return stackView
		}()
		
		contentView.addSubview(stackView)
		contentView.addSubview(moreButton)
		
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -42),
			
			imageView.heightAnchor.constraint(equalToConstant: 48),
			imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.25),
			imageView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
			
			moreButton.widthAnchor.constraint(equalToConstant: 30),
			moreButton.heightAnchor.constraint(equalToConstant: 30),
			moreButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
		])
	}
	
	public func configureCell(_ track: PlayableWitness, isMovable: Bool) {
		titleLabel.text = track.title
		subtitleLabel.text = track.artist
		
		if let thumbnailURL = track.thumbnailURL {
			imageView.kf.setImage(with: thumbnailURL)
		}
		
		moreButton.isHidden = isMovable
	}
	
	@objc private func moreButtonTapped(_ sender: UIButton) {
		
	}
}

struct TrackCell_Previews: PreviewProvider {
	static var previews: some View {
		UIViewPreview {
			TrackCell()
		}
	}
}

struct UpnextView_Previews: PreviewProvider {
	static var previews: some View {
		UIViewPreview {
			UpnextView()
		}
	}
}
