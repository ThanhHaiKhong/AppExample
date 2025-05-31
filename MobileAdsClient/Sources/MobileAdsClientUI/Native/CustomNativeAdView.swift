//
//  CustomNativeAdView.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 17/2/25.
//

import GoogleMobileAds
import UIKit

public class CustomNativeAdView: NativeAdView {
    
    private var heightConstraint: NSLayoutConstraint!
    private var currentMultiplier: CGFloat = 9.0 / 16.0
    private let defaultSpacing: CGFloat = 16
    
    private lazy var adContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(red: 122 / 255, green: 159 / 255, blue: 126 / 255, alpha: 1)
        
        return view
    }()
    
    private lazy var adHeadlineLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "Ad Headline Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 18)
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
        let label = PaddedLabel(padding: UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6))
        label.accessibilityIdentifier = "Ad Attribution Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Sponsored"
        label.textAlignment = .center
        label.backgroundColor = .systemBlue
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        
        return label
    }()
    
    private lazy var adIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.accessibilityIdentifier = "Ad Icon Image View"
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
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
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = false
        
        return button
    }()
    
    private lazy var adBodyLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "Ad Body Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private lazy var adStoreLabel: PaddedLabel = {
        let label = PaddedLabel(padding: UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6))
        label.accessibilityIdentifier = "Ad Store Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .systemGreen
        label.font = .systemFont(ofSize: 13, weight: .semibold)
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
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.text = "Free"
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.backgroundColor = .systemGreen
        
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
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods

extension CustomNativeAdView {
    private func setupUI() {
        addBlur(style: .dark)
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        let storeStack = CustomStackView()
        storeStack.accessibilityIdentifier = "Store Stack"
        storeStack.axis = .horizontal
        storeStack.spacing = 8
        storeStack.alignment = .center
        storeStack.distribution = .fill
        storeStack.translatesAutoresizingMaskIntoConstraints = false
        storeStack.addArrangedSubview(adStoreLabel)
        storeStack.addArrangedSubview(adPriceLabel)
        
        let attributionStack = UIStackView()
        attributionStack.accessibilityIdentifier = "Attribution Stack"
        attributionStack.axis = .horizontal
        attributionStack.spacing = 8
        attributionStack.alignment = .center
        attributionStack.distribution = .fill
        attributionStack.translatesAutoresizingMaskIntoConstraints = false
        attributionStack.addArrangedSubview(adAttributionLabel)
        attributionStack.addArrangedSubview(adRatingImageView)
        
        let labelStack = CustomStackView()
        labelStack.accessibilityIdentifier = "Label Stack"
        labelStack.axis = .vertical
        labelStack.spacing = 8
        labelStack.alignment = .leading
        labelStack.distribution = .fill
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.addArrangedSubview(adHeadlineLabel)
        labelStack.addArrangedSubview(adSponsorLabel)
        labelStack.addArrangedSubview(attributionStack)
        labelStack.addArrangedSubview(storeStack)
        
        headlineStack.addArrangedSubview(adIconImageView)
        headlineStack.addArrangedSubview(labelStack)
        
        let bodyStack = CustomStackView()
        bodyStack.accessibilityIdentifier = "Body Stack"
        bodyStack.axis = .vertical
        bodyStack.spacing = defaultSpacing
        bodyStack.alignment = .leading
        bodyStack.distribution = .fill
        bodyStack.translatesAutoresizingMaskIntoConstraints = false
        bodyStack.addArrangedSubview(headlineStack)
        bodyStack.addArrangedSubview(adBodyLabel)
        bodyStack.addArrangedSubview(actionButton)
        
        adContainerView.addSubview(contentView)
        adContainerView.addSubview(bodyStack)
        
        addSubview(adContainerView)
        
        heightConstraint = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: currentMultiplier, constant: 0)
        
        NSLayoutConstraint.activate([
            adContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            adContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            adContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            adContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            contentView.topAnchor.constraint(equalTo: adContainerView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: adContainerView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: adContainerView.trailingAnchor),
            
            bodyStack.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: defaultSpacing),
            bodyStack.leadingAnchor.constraint(equalTo: adContainerView.leadingAnchor, constant: 20),
            bodyStack.trailingAnchor.constraint(equalTo: adContainerView.trailingAnchor, constant: -20),
            
            actionButton.leadingAnchor.constraint(equalTo: bodyStack.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: bodyStack.trailingAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 46),
            
            adIconImageView.widthAnchor.constraint(equalToConstant: 80),
            adIconImageView.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
}

// MARK: - Public Methods

extension CustomNativeAdView {
    public func configure(with nativeAd: NativeAd) {
        updateAspectRatio(for: nativeAd.mediaContent.aspectRatio)
        updateUI(with: nativeAd)
        updateViewBindings(for: nativeAd)
        updateVisibility(for: nativeAd)
        
        self.nativeAd = nativeAd
    }

    // MARK: - Update Aspect Ratio
    
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
        } completion: { completed in
            
        }
    }

    // MARK: - Update UI Elements
    
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
                    self.adStoreLabel.text = nativeAd.store?.capitalized
                case self.adPriceLabel:
                    self.adPriceLabel.text = nativeAd.price?.capitalized
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

    // MARK: - Bind Views to Native Ad
    
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
    }

    // MARK: - Update View Visibility
    
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
        
        let validViews = views.compactMap { view, data in
            view.map { ($0, data != nil) }
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            validViews.forEach { view, isVisible in
                view.alpha = isVisible ? 1 : 0
            }
        }, completion: { _ in
            validViews.forEach { view, isVisible in
                if let stackView = view.superview as? CustomStackView {
                    let viewName = view.accessibilityIdentifier ?? String(describing: type(of: view))
#if DEBUG
                    print("- \(viewName) -> \(isVisible ? "Hiển thị ✅" : "Ẩn ❌") trong: \(stackView.accessibilityIdentifier ?? String(describing: type(of: stackView)))")
                    #endif
                    stackView.setVisibility(for: view, isVisible: isVisible)
                } else {
                    view.isHidden = !isVisible
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
    
    // MARK: - Calculate Total Height
    
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
