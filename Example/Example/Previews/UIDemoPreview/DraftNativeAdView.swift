//
//  DraftNativeAdView.swift
//  Example
//
//  Created by Thanh Hai Khong on 24/6/25.
//

import GoogleMobileAds
import MobileAdsClientUI
import UIKit

public class DraftNativeAdView: NativeAdView {
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - SetupViews
	
	private lazy var contentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = UIColor(red: 234 / 255, green: 240 / 255, blue: 253 / 255, alpha: 1)
		view.layer.cornerRadius = 5
		view.layer.masksToBounds = true
		return view
	}()
	
	public lazy var containerView: UIImageView = {
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.accessibilityIdentifier = "Ad Container View"
		view.contentMode = .scaleAspectFill
		view.layer.cornerRadius = 5
		view.layer.masksToBounds = true
		view.backgroundColor = UIColor(red: 234 / 255, green: 240 / 255, blue: 253 / 255, alpha: 1)
		
		return view
	}()
	
	public lazy var headlineLabel: UILabel = {
		let label = UILabel()
		label.accessibilityIdentifier = "Ad Headline Label"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.font = .boldSystemFont(ofSize: 17)
		label.textColor = UIColor(red: 66 / 255, green: 66 / 255, blue: 66 / 255, alpha: 1)
		label.text = "Ad Headline"
		
		return label
	}()
	
	public lazy var sponsorLabel: UILabel = {
		let label = UILabel()
		label.accessibilityIdentifier = "Ad Sponsor Label"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.textColor = .secondaryLabel
		label.text = "Ad Sponsor"
		label.font = .systemFont(ofSize: 14, weight: .medium)
		
		return label
	}()
	
	public lazy var attributionLabel: PaddedLabel = {
		let label = PaddedLabel(padding: UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6))
		label.accessibilityIdentifier = "Ad Attribution Label"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .systemBlue
		label.text = "Sponsored"
		label.textAlignment = .center
		label.layer.cornerRadius = 4
		label.layer.masksToBounds = true
		label.layer.borderColor = UIColor.systemBlue.cgColor
		label.layer.borderWidth = 1.4
		label.font = .systemFont(ofSize: 13, weight: .bold)
		
		return label
	}()
	
	public lazy var iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.accessibilityIdentifier = "Ad Icon Image View"
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.layer.cornerRadius = 5
		imageView.layer.masksToBounds = true
		
		return imageView
	}()
	
	public lazy var ratingImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.accessibilityIdentifier = "Ad Rating Image View"
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .left
		
		return imageView
	}()
	
	public lazy var actionButton: UIButton = {
		let button = UIButton()
		button.accessibilityIdentifier = "Ad Action Button"
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Install Now", for: .normal)
		button.backgroundColor = .systemBlue.withAlphaComponent(0.15)
		button.setTitleColor(.systemBlue, for: .normal)
		button.titleLabel?.font = .boldSystemFont(ofSize: 15)
		button.layer.cornerRadius = 5
		button.layer.masksToBounds = true
		button.isUserInteractionEnabled = false
		
		return button
	}()
	
	public lazy var bodyLabel: UILabel = {
		let label = UILabel()
		label.accessibilityIdentifier = "Ad Body Label"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.font = .systemFont(ofSize: 13, weight: .regular)
		label.textAlignment = .left
		label.textColor = .secondaryLabel
		
		return label
	}()
	
	public lazy var storeLabel: PaddedLabel = {
		let label = PaddedLabel(padding: UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6))
		label.accessibilityIdentifier = "Ad Store Label"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.textColor = .systemGreen
		label.textAlignment = .center
		label.backgroundColor = .systemGreen.withAlphaComponent(0.15)
		label.font = .boldSystemFont(ofSize: 15)
		label.text = "App Store"
		label.layer.cornerRadius = 5
		label.layer.masksToBounds = true
		
		return label
	}()
	
	public lazy var priceLabel: PaddedLabel = {
		let label = PaddedLabel(padding: UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6))
		label.accessibilityIdentifier = "Ad Price Label"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.textColor = .systemGreen
		label.textAlignment = .center
		label.font = .boldSystemFont(ofSize: 15)
		label.text = "Free"
		label.layer.cornerRadius = 5
		label.layer.masksToBounds = true
		label.backgroundColor = .systemGreen.withAlphaComponent(0.15)
		
		return label
	}()
	
	public lazy var mediaContentView: MediaView = {
		let view = MediaView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 5
		view.layer.masksToBounds = true
		
		return view
	}()
}

// MARK: - Supporting Methods

extension DraftNativeAdView {
	
	private func setupViews() {
		addBlur(style: .systemMaterial)
		
		let storeStack = AutoHidingStackView(arrangedSubviews: [actionButton, storeLabel, priceLabel])
		storeStack.accessibilityIdentifier = "Store Stack"
		storeStack.axis = .horizontal
		storeStack.spacing = 8
		storeStack.alignment = .fill
		storeStack.distribution = .fillEqually
		storeStack.translatesAutoresizingMaskIntoConstraints = false
		
		let attributionStack = AutoHidingStackView(arrangedSubviews: [attributionLabel, sponsorLabel])
		attributionStack.accessibilityIdentifier = "Attribution Stack"
		attributionStack.axis = .horizontal
		attributionStack.spacing = 8
		attributionStack.alignment = .center
		attributionStack.distribution = .fill
		attributionStack.translatesAutoresizingMaskIntoConstraints = false
		
		let labelStack = AutoHidingStackView(arrangedSubviews: [headlineLabel, attributionStack, ratingImageView])
		labelStack.translatesAutoresizingMaskIntoConstraints = false
		labelStack.accessibilityIdentifier = "Label Stack"
		labelStack.axis = .vertical
		labelStack.spacing = 5
		labelStack.alignment = .leading
		labelStack.distribution = .fillProportionally
		
		let headerStack = AutoHidingStackView(arrangedSubviews: [iconImageView, labelStack])
		headerStack.translatesAutoresizingMaskIntoConstraints = false
		headerStack.accessibilityIdentifier = "Header Stack"
		headerStack.axis = .horizontal
		headerStack.spacing = 8
		headerStack.alignment = .center
		headerStack.distribution = .fill
		
		let stackView = AutoHidingStackView(arrangedSubviews: [containerView, headerStack, bodyLabel, storeStack])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.accessibilityIdentifier = "Main Stack"
		stackView.axis = .vertical
		stackView.spacing = 12
		stackView.alignment = .fill
		stackView.distribution = .fill
		
		containerView.image = UIImage(named: "placeholder_image_1")
		iconImageView.image = UIImage(named: "placeholder_image")
		ratingImageView.image = UIImage.fromSPM(named: "stars_5")
		headlineLabel.text = "The new era of fashion is here"
		sponsorLabel.text = "Polo Ralph Lauren"
		bodyLabel.text = "This is a sample body text for the ad. It provides additional information about the product or service being advertised."
		
		containerView.setContentHuggingPriority(.defaultHigh, for: .vertical)
		containerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		
		containerView.addSubview(mediaContentView)
		addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
			
			containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
			
			mediaContentView.topAnchor.constraint(equalTo: containerView.topAnchor),
			mediaContentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			mediaContentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			mediaContentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			
			storeStack.heightAnchor.constraint(equalToConstant: 40),
			
			iconImageView.widthAnchor.constraint(equalToConstant: 50),
			iconImageView.heightAnchor.constraint(equalToConstant: 50),
		])
	}
	
	private func updateUI(with nativeAd: NativeAd) {
		let viewsToAnimate: [UIView] = [
			iconImageView,
			headlineLabel,
			ratingImageView,
			sponsorLabel,
			storeLabel,
			priceLabel,
			bodyLabel,
			actionButton,
			mediaContentView
		]
		
		for view in viewsToAnimate {
			UIView.transition(with: view, duration: 0.3, options: .transitionFlipFromLeft, animations: {
				switch view {
				case self.iconImageView:
					self.iconImageView.image = nativeAd.icon?.image
					
				case self.headlineLabel:
					self.headlineLabel.text = nativeAd.headline?.capitalized
					
				case self.ratingImageView:
					self.ratingImageView.image = self.imageOfStars(from: nativeAd.starRating)
					
				case self.sponsorLabel:
					self.sponsorLabel.text = nativeAd.advertiser
					
				case self.storeLabel:
					self.storeLabel.text = nativeAd.store?.uppercased()
					
				case self.priceLabel:
					self.priceLabel.text = nativeAd.price?.uppercased()
					
				case self.bodyLabel:
					self.bodyLabel.text = nativeAd.body
					
				case self.actionButton:
					self.actionButton.setTitle(nativeAd.callToAction?.uppercased(), for: .normal)
					
				case self.mediaContentView:
					self.mediaContentView.mediaContent = nativeAd.mediaContent
					self.mediaContentView.contentMode = .scaleAspectFill
					
				default:
					break
				}
			})
		}
	}
	
	private func updateViewBindings(for nativeAd: NativeAd) {
		self.iconView = iconImageView
		self.headlineView = headlineLabel
		self.advertiserView = sponsorLabel
		self.starRatingView = ratingImageView
		self.storeView = storeLabel
		self.priceView = priceLabel
		self.callToActionView = actionButton
		self.bodyView = bodyLabel
		self.mediaView = mediaContentView
	}
	
	private func updateVisibility(for nativeAd: NativeAd) {
		let views: [(UIView?, Any?)] = [
			(iconView, nativeAd.icon?.image),
			(headlineView, nativeAd.headline),
			(advertiserView, nativeAd.advertiser),
			(starRatingView, nativeAd.starRating),
			(bodyView, nativeAd.body),
			(callToActionView, nativeAd.callToAction),
			(storeView, nativeAd.store),
			(priceView, nativeAd.price)
		]
		
		func isVisibleData(_ data: Any?) -> Bool {
			guard let data = data else { return false }
			
			if let string = data as? String {
				return !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
			}
			
			if let nsString = data as? NSString {
				return !nsString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
			}
			
			if let number = data as? NSNumber {
				return number.doubleValue > 0
			}
			
			return true
		}
		
		let validViews: [(UIView, Bool)] = views.map { view, data in
			guard let view = view else { return nil }
			return (view, isVisibleData(data))
		}.compactMap { $0 }
		
		UIView.animate(withDuration: 0.3) {
			validViews.forEach { view, isVisible in
				view.isHidden = !isVisible
			}
		}
	}
	
	private func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
		guard let rating = starRating?.doubleValue else {
			return nil
		}
		
		if rating >= 5 {
			return UIImage.fromSPM(named: "stars_5")
		} else if rating >= 4.5 {
			return UIImage.fromSPM(named: "stars_4_5")
		} else if rating >= 4 {
			return UIImage.fromSPM(named: "stars_4")
		} else if rating >= 3.5 {
			return UIImage.fromSPM(named: "stars_3_5")
		} else {
			return nil
		}
	}
}

// MARK: - Public Methods

extension DraftNativeAdView {
	
	public func configure(with nativeAd: NativeAd) {
		self.nativeAd = nativeAd
		
		updateViewBindings(for: nativeAd)
		updateUI(with: nativeAd)
		updateVisibility(for: nativeAd)
	}
}
