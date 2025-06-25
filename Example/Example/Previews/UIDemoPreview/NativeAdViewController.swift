//
//  NativeAdViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 24/6/25.
//

import MobileAdsClientUI
import UIKitPreviews
import SwiftUI
import UIKit

class NativeAdViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemBackground
		setupViews()
		navigationItem.title = "Native Ad"
	}
	
	// MARK: - SetupViews
	
	private lazy var containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 5
		view.layer.masksToBounds = true
		view.backgroundColor = .systemYellow
		return view
	}()
	
	private lazy var nativeAd: DraftNativeAdView = {
        let nativeAd = DraftNativeAdView()
        nativeAd.translatesAutoresizingMaskIntoConstraints = false
		nativeAd.layer.cornerRadius = 5
		nativeAd.layer.masksToBounds = true
        return nativeAd
    }()
	
	private lazy var verticalStack: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 12
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	private func setupViews() {
		let titles: [String] = ["Media", "Icon", "Headline", "Attribute", "Sponsor", "Rating", "Body", "Action", "Store", "Price"]
		let icons: [String] = ["film.fill", "theatermasks.fill", "storefront.fill", "tag.fill", "mail.fill", "star.fill", "message.fill", "dumbbell.fill", "storefront.fill", "dollarsign.bank.building.fill"]
		
		let buttonStacks = createButtonStacks(titles: titles, icons: icons)
		buttonStacks.forEach { verticalStack.addArrangedSubview($0) }
		
		containerView.addSubview(nativeAd)
		view.addSubview(containerView)
		view.addSubview(verticalStack)
		
		NSLayoutConstraint.activate([
			containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			containerView.heightAnchor.constraint(equalToConstant: 430),
			
			nativeAd.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			nativeAd.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			nativeAd.topAnchor.constraint(equalTo: containerView.topAnchor),
			nativeAd.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			
			verticalStack.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
			verticalStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			verticalStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
		])
	}
	
	func createButtonStacks(titles: [String], icons: [String]) -> [UIStackView] {
		var buttonStacks: [UIStackView] = []
		
		for i in stride(from: 0, to: titles.count, by: 3) {
			let horizontalStack = UIStackView()
			horizontalStack.axis = .horizontal
			horizontalStack.spacing = 12
			horizontalStack.alignment = .center
			horizontalStack.distribution = .fillEqually
			
			let end = min(i + 3, titles.count)
			for j in i..<end {
				let title = titles[j]
				let icon = icons[j]
				
				let button = UIButton(type: .system)
				button.accessibilityIdentifier = title
				button.tag = j
				
				var configuration = UIButton.Configuration.filled()
				configuration.title = title
				configuration.image = UIImage(systemName: icon)
				configuration.imagePlacement = .top
				configuration.imagePadding = 8
				configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20)
				configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
				var container = AttributeContainer()
				container.font = UIFont.boldSystemFont(ofSize: 16)
				configuration.attributedTitle = AttributedString(title, attributes: container)
				
				button.configuration = configuration
				button.configurationUpdateHandler = { button in
					var updatedConfig = button.configuration
					if button.isSelected {
						updatedConfig?.baseBackgroundColor = .systemBlue
						updatedConfig?.baseForegroundColor = .white
					} else {
						updatedConfig?.baseBackgroundColor = .systemFill
						updatedConfig?.baseForegroundColor = .systemBlue
					}
					button.configuration = updatedConfig
				}

				button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
				
				horizontalStack.addArrangedSubview(button)
			}
			
			buttonStacks.append(horizontalStack)
		}
		
		return buttonStacks
	}
	
	@objc
	private func buttonTapped(_ sender: UIButton) {
		UIView.transition(with: sender, duration: 0.3, options: .transitionFlipFromRight) {
			sender.isSelected.toggle()
		} completion: { _ in
			UIView.animate(withDuration: 0.15) {
				switch sender.tag {
				case 0:
					self.nativeAd.containerView.isHidden = sender.isSelected
				case 1:
					self.nativeAd.iconImageView.isHidden = sender.isSelected
				case 2:
					self.nativeAd.headlineLabel.isHidden = sender.isSelected
				case 3:
					self.nativeAd.attributionLabel.isHidden = sender.isSelected
				case 4:
					self.nativeAd.sponsorLabel.isHidden = sender.isSelected
				case 5:
					self.nativeAd.ratingImageView.isHidden = sender.isSelected
				case 6:
					self.nativeAd.bodyLabel.isHidden = sender.isSelected
				case 7:
					self.nativeAd.actionButton.isHidden = sender.isSelected
				case 8:
					self.nativeAd.storeLabel.isHidden = sender.isSelected
				case 9:
					self.nativeAd.priceLabel.isHidden = sender.isSelected
				default:
					break
				}
			}
		}
	}
}

struct NativeAdViewController_Previews: PreviewProvider {
	static var previews: some View {
		UIViewControllerPreview {
			NativeAdViewController()
		}
	}
}
