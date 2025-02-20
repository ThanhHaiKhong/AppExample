//
//  DemoViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 18/2/25.
//

import UIKit
import GoogleMobileAds
import MobileAdsClientUI

class DemoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetState))
        navigationItem.leftBarButtonItem = resetButton
        
        let removeSpacingButton = UIBarButtonItem(title: "Pop View", style: .plain, target: self, action: #selector(resetSpacing))
        navigationItem.rightBarButtonItem = removeSpacingButton
    }
    
    private var heightConstraint: NSLayoutConstraint!
    private var currentMultiplier: CGFloat = 9.0 / 16.0
    
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
        label.backgroundColor = .red
        
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
        label.backgroundColor = .purple
        
        return label
    }()
    
    private lazy var adAttributionLabel: PaddedLabel = {
        let label = PaddedLabel(padding: .init(top: 5, left: 10, bottom: 5, right: 10))
        label.accessibilityIdentifier = "Ad Attribution Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Sponsored"
        label.textAlignment = .center
        label.backgroundColor = .systemBlue
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        
        return label
    }()
    
    private lazy var adIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.accessibilityIdentifier = "Ad Icon Image View"
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .systemYellow
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "photo")
        
        return imageView
    }()
    
    private lazy var adRatingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.accessibilityIdentifier = "Ad Rating Image View"
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .left
        imageView.image = UIImage(systemName: "star.fill")
        imageView.tintColor = .white
        imageView.backgroundColor = .systemYellow
        
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
        let label = PaddedLabel(padding: .init(top: 5, left: 10, bottom: 5, right: 10))
        label.accessibilityIdentifier = "Ad Store Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .systemGreen
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.text = "App Store"
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        
        return label
    }()
    
    private lazy var adPriceLabel: PaddedLabel = {
        let label = PaddedLabel(padding: .init(top: 5, left: 10, bottom: 5, right: 10))
        label.accessibilityIdentifier = "Ad Price Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.text = "Free"
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.backgroundColor = .systemGreen
        
        return label
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private lazy var storeStack: CustomStackView = {
        let storeStack = CustomStackView(arrangedSubviews: [adStoreLabel, adPriceLabel])
        storeStack.accessibilityIdentifier = "Store Stack"
        storeStack.axis = .horizontal
        storeStack.spacing = 12
        storeStack.alignment = .center
        storeStack.distribution = .fillEqually
        storeStack.translatesAutoresizingMaskIntoConstraints = false
        storeStack.backgroundColor = .orange
        
        return storeStack
    }()
    
    private lazy var titleStack: CustomStackView = {
        let stack = CustomStackView(arrangedSubviews: [adHeadlineLabel, adSponsorLabel, attributionStack, storeStack])
        stack.accessibilityIdentifier = "Title Stack"
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .gray
        
        return titleStack
    }()
    
    private lazy var attributionStack: CustomStackView = {
        let attributionStack = CustomStackView(arrangedSubviews: [adAttributionLabel, adRatingImageView])
        attributionStack.accessibilityIdentifier = "Attribution Stack"
        attributionStack.axis = .horizontal
        attributionStack.spacing = 12
        attributionStack.alignment = .center
        attributionStack.distribution = .fillProportionally
        attributionStack.translatesAutoresizingMaskIntoConstraints = false
        attributionStack.backgroundColor = .systemTeal
        
        return attributionStack
    }()
    
    private func setupUI() {
        let headlineStack = CustomStackView(arrangedSubviews: [adIconImageView, titleStack])
        headlineStack.accessibilityIdentifier = "Headline Stack"
        headlineStack.axis = .horizontal
        headlineStack.spacing = 12
        headlineStack.alignment = .center
        headlineStack.distribution = .fillProportionally
        headlineStack.translatesAutoresizingMaskIntoConstraints = false
        headlineStack.backgroundColor = .systemMint
        
        view.addSubview(headlineStack)
        
        NSLayoutConstraint.activate([
            headlineStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headlineStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            headlineStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headlineStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            adIconImageView.widthAnchor.constraint(equalToConstant: 80),
            adIconImageView.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
    
    @objc private func resetState() {
        
    }
    
    @objc private func resetSpacing() {
        
    }
}
