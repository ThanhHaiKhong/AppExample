//
//  FlexibleNativeAdView.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 9/6/25.
//

import GoogleMobileAds
import UIKit

public class FlexibleNativeAdView: NativeAdView {
	
	private var heightConstraint: NSLayoutConstraint!
	private var currentMultiplier: CGFloat = 9.0 / 16.0
	private let defaultSpacing: CGFloat = 16
	
	private lazy var adContainerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 5
		view.layer.masksToBounds = true
		view.backgroundColor = UIColor(red: 234 / 255, green: 240 / 255, blue: 253 / 255, alpha: 1)
		
		return view
	}()
	
	private lazy var adHeadlineLabel: UILabel = {
		let label = UILabel()
		label.accessibilityIdentifier = "Ad Headline Label"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.font = .boldSystemFont(ofSize: 15)
		label.textColor = UIColor(red: 66 / 255, green: 66 / 255, blue: 66 / 255, alpha: 1)
		label.text = "Ad Headline"
		
		return label
	}()
	
	private lazy var adSponsorLabel: UILabel = {
		let label = UILabel()
		label.accessibilityIdentifier = "Ad Sponsor Label"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.textColor = .secondaryLabel
		label.text = "Ad Sponsor"
		label.font = .systemFont(ofSize: 14, weight: .medium)
		
		return label
	}()
	
	private lazy var adAttributionLabel: PaddedLabel = {
		let label = PaddedLabel(padding: UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6))
		label.accessibilityIdentifier = "Ad Attribution Label"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .systemBlue
		label.text = "Ad"
		label.textAlignment = .center
		label.layer.cornerRadius = 4
		label.layer.masksToBounds = true
		label.layer.borderColor = UIColor.systemBlue.cgColor
		label.layer.borderWidth = 1.4
		label.font = .systemFont(ofSize: 13, weight: .bold)
		
		return label
	}()
	
	private lazy var adIconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.accessibilityIdentifier = "Ad Icon Image View"
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.layer.cornerRadius = 5
		imageView.layer.masksToBounds = true
		
		return imageView
	}()
	
	private lazy var adRatingImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.accessibilityIdentifier = "Ad Rating Image View"
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .left
		
		return imageView
	}()
	
	private lazy var actionButton: UIButton = {
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
	
	private lazy var adBodyLabel: UILabel = {
		let label = UILabel()
		label.accessibilityIdentifier = "Ad Body Label"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.font = .systemFont(ofSize: 13, weight: .regular)
		label.textAlignment = .left
		label.textColor = .secondaryLabel
		
		return label
	}()
	
	private lazy var adStoreLabel: PaddedLabel = {
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
	
	private lazy var adPriceLabel: PaddedLabel = {
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
	
	private lazy var contentView: MediaView = {
		let view = MediaView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.masksToBounds = true
		
		return view
	}()
	
	private lazy var headlineStack: CustomStackView = {
		let stack = CustomStackView()
		stack.accessibilityIdentifier = "Headline Stack"
		stack.axis = .horizontal
		stack.spacing = 12
		stack.alignment = .center
		stack.distribution = .fill
		stack.translatesAutoresizingMaskIntoConstraints = false
		
		return stack
	}()
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Public Methods

extension FlexibleNativeAdView {
	
	public func configure(with nativeAd: NativeAd) {
		updateUI(with: nativeAd)
		updateViewBindings(for: nativeAd)
		updateVisibility(for: nativeAd)
		
		self.nativeAd = nativeAd
	}
	
	public func calculateTotalHeight() -> CGFloat {
		let bottomPadding: CGFloat = 20
		let verticalPadding: CGFloat = 16
		let contentHeight = contentView.frame.height
		let headlineHeight = headlineStack.frame.height
		let bodyHeight = adBodyLabel.frame.height
		let buttonHeight = actionButton.frame.height
		let totalHeight = contentHeight + headlineHeight + bodyHeight + buttonHeight + defaultSpacing * 3 + bottomPadding + verticalPadding
		#if DEBUG
		print("✅ Total height: \(totalHeight) - Body height: \(bodyHeight) - Media height: \(contentHeight)")
		#endif
		return totalHeight
	}
}

// MARK: - Supporting Methods

extension FlexibleNativeAdView {
	
	private func setupViews() {
		addBlur(style: .dark)
		layer.cornerRadius = 5
		layer.masksToBounds = true
		
		let storeStack = CustomStackView()
		storeStack.accessibilityIdentifier = "Store Stack"
		storeStack.axis = .horizontal
		storeStack.spacing = 8
		storeStack.alignment = .center
		storeStack.distribution = .fillEqually
		storeStack.translatesAutoresizingMaskIntoConstraints = false
		storeStack.addArrangedSubview(actionButton)
		storeStack.addArrangedSubview(adStoreLabel)
		storeStack.addArrangedSubview(adPriceLabel)
		
		let attributionStack = CustomStackView()
		attributionStack.accessibilityIdentifier = "Attribution Stack"
		attributionStack.axis = .horizontal
		attributionStack.spacing = 8
		attributionStack.alignment = .center
		attributionStack.distribution = .fill
		attributionStack.translatesAutoresizingMaskIntoConstraints = false
		attributionStack.addArrangedSubview(adAttributionLabel)
		attributionStack.addArrangedSubview(adSponsorLabel)
		
		let labelStack = CustomStackView()
		labelStack.accessibilityIdentifier = "Label Stack"
		labelStack.axis = .vertical
		labelStack.spacing = 4
		labelStack.alignment = .leading
		labelStack.distribution = .fill
		labelStack.translatesAutoresizingMaskIntoConstraints = false
		labelStack.addArrangedSubview(adHeadlineLabel)
		labelStack.addArrangedSubview(attributionStack)
		labelStack.addArrangedSubview(adRatingImageView)
		
		let headerStack = UIStackView()
		headerStack.accessibilityIdentifier = "Header Stack"
		headerStack.axis = .horizontal
		headerStack.spacing = 8
		headerStack.alignment = .top
		headerStack.distribution = .fill
		headerStack.translatesAutoresizingMaskIntoConstraints = false
		headerStack.addArrangedSubview(adIconImageView)
		headerStack.addArrangedSubview(labelStack)
		
		let bodyStack = CustomStackView()
		bodyStack.accessibilityIdentifier = "Body Stack"
		bodyStack.axis = .vertical
		bodyStack.spacing = 8
		bodyStack.alignment = .leading
		bodyStack.distribution = .fill
		bodyStack.translatesAutoresizingMaskIntoConstraints = false
		bodyStack.setContentHuggingPriority(.required, for: .vertical)
		bodyStack.setContentCompressionResistancePriority(.required, for: .vertical)
		bodyStack.addArrangedSubview(headerStack)
		bodyStack.addArrangedSubview(adBodyLabel)
		bodyStack.addArrangedSubview(storeStack)
		
		adIconImageView.setContentHuggingPriority(.required, for: .horizontal)
		adIconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
		
		adContainerView.addSubview(contentView)
		adContainerView.addSubview(bodyStack)
		
		addSubview(adContainerView)
		
		NSLayoutConstraint.activate([
			adContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			adContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
			adContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
			adContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
			
			contentView.topAnchor.constraint(equalTo: adContainerView.topAnchor),
			contentView.leadingAnchor.constraint(equalTo: adContainerView.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: adContainerView.trailingAnchor),
			
			bodyStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: 8),
			bodyStack.leadingAnchor.constraint(equalTo: adContainerView.leadingAnchor, constant: 8),
			bodyStack.trailingAnchor.constraint(equalTo: adContainerView.trailingAnchor, constant: -8),
			bodyStack.bottomAnchor.constraint(equalTo: adContainerView.bottomAnchor, constant: -8),
			
			adIconImageView.widthAnchor.constraint(equalToConstant: 60),
			adIconImageView.heightAnchor.constraint(equalToConstant: 60),
			
			headerStack.leadingAnchor.constraint(equalTo: bodyStack.leadingAnchor),
			headerStack.trailingAnchor.constraint(equalTo: bodyStack.trailingAnchor),
			
			storeStack.leadingAnchor.constraint(equalTo: bodyStack.leadingAnchor),
			storeStack.trailingAnchor.constraint(equalTo: bodyStack.trailingAnchor),

			adStoreLabel.heightAnchor.constraint(equalToConstant: 40),
			adPriceLabel.heightAnchor.constraint(equalToConstant: 40),
			actionButton.heightAnchor.constraint(equalToConstant: 40),
			
			adAttributionLabel.heightAnchor.constraint(equalToConstant: 22),
			adRatingImageView.heightAnchor.constraint(equalToConstant: 22),
		])
	}
	
	private func updateAspectRatio(for aspectRatio: CGFloat) {
		guard aspectRatio > 0, aspectRatio != currentMultiplier else { return }
		
		heightConstraint.isActive = false
		heightConstraint = NSLayoutConstraint(
			item: contentView,
			attribute: .height,
			relatedBy: .equal,
			toItem: contentView,
			attribute: .width,
			multiplier: 1.0 / aspectRatio,
			constant: 0
		)
		heightConstraint.isActive = true
		currentMultiplier = 1.0 / aspectRatio
		
		UIView.animate(withDuration: 0.5) {
			self.layoutIfNeeded()
		}
	}
	
	private func updateUI(with nativeAd: NativeAd) {
		let viewsToAnimate: [UIView] = [
			adIconImageView,
			adHeadlineLabel,
			adRatingImageView,
			adSponsorLabel,
			adStoreLabel,
			adPriceLabel,
			adBodyLabel,
			actionButton,
			contentView
		]
		
		for view in viewsToAnimate {
			UIView.transition(with: view, duration: 0.3, options: .transitionFlipFromLeft, animations: {
				switch view {
				case self.adIconImageView:
					self.adIconImageView.image = nativeAd.icon?.image
					
				case self.adHeadlineLabel:
					self.adHeadlineLabel.text = nativeAd.headline?.capitalized
					
				case self.adRatingImageView:
					self.adRatingImageView.image = self.imageOfStars(from: nativeAd.starRating)
					
				case self.adSponsorLabel:
					self.adSponsorLabel.text = nativeAd.advertiser
					
				case self.adStoreLabel:
					self.adStoreLabel.text = nativeAd.store?.uppercased()
					
				case self.adPriceLabel:
					self.adPriceLabel.text = nativeAd.price?.uppercased()
					
				case self.adBodyLabel:
					self.adBodyLabel.text = nativeAd.body
					
				case self.actionButton:
					self.actionButton.setTitle(nativeAd.callToAction?.uppercased(), for: .normal)
					
				case self.contentView:
					self.contentView.mediaContent = nativeAd.mediaContent
					self.contentView.contentMode = .scaleAspectFit
					
				default:
					break
				}
			})
		}
	}
	
	private func updateViewBindings(for nativeAd: NativeAd) {
		self.iconView = adIconImageView
		self.headlineView = adHeadlineLabel
		self.advertiserView = adSponsorLabel
		self.starRatingView = adRatingImageView
		self.storeView = adStoreLabel
		self.priceView = adPriceLabel
		self.callToActionView = actionButton
		self.bodyView = adBodyLabel
		self.mediaView = contentView
		self.mediaView?.contentMode = .scaleToFill
	}
	
	private func updateVisibility(for nativeAd: NativeAd) {
		let views: [(UIView?, Any?)] = [
			(iconView, nativeAd.icon),
			(headlineView, nativeAd.headline),
			(advertiserView, nativeAd.advertiser),
			(starRatingView, nativeAd.starRating),
			(bodyView, nativeAd.body),
			(callToActionView, nativeAd.callToAction),
			(storeView, nativeAd.store),
			(priceView, nativeAd.price)
		]
		
		let values = views.map(\.1)
		
		func isVisibleData(_ data: Any?) -> Bool {
			guard let data = data else { return false }
			
			if let string = data as? String {
				return !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
			}
			
			if let nsString = data as? NSString {
				return !nsString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
			}
			
			return true
		}
		
		let validViews: [(UIView, Bool)] = views.map { view, data in
			guard let view = view else { return nil }
			return (view, isVisibleData(data))
		}.compactMap { $0 }
		
		UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
			validViews.forEach { view, isVisible in
				view.alpha = isVisible ? 1 : 0
			}
		}, completion: { _ in
			UIView.animate(withDuration: 0.3) {
				validViews.forEach { view, isVisible in
					view.isHidden = !isVisible
					if let stackView = view.superview as? CustomStackView {
						stackView.setCustomSpacing(isVisible ? 8 : 0, after: view)
					}
				}
			}
		})
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

/*
 #if DEBUG
 let viewName = view.accessibilityIdentifier ?? String(describing: type(of: view))
 print("- \(viewName) -> \(isVisible ? "Visible ✅" : "Hidden ❌") IN: \(stackView.accessibilityIdentifier ?? String(describing: type(of: stackView)))")
 #endif
 */
