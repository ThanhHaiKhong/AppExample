//
//  ViewController.swift
//  UIDemoViewController
//
//  Created by Thanh Hai Khong on 23/6/25.
//

import UIKitPreviews
import UIComponents
import SwiftUI
import UIKit

class UIDemoViewController: UIViewController {
	
	public var views: [UIView] = []
	public var allSubviews: [UIView] = []
	public var reserveSubviews: [UIView] = []

	override func viewDidLoad() {
		super.viewDidLoad()
	
		setupNavigationBar()
		setupViews()
		setupConstraints()
	}
	
	// MARK: - SetupViews
	
	private lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "photo")
		imageView.backgroundColor = .lightGray
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.layer.cornerRadius = 5
		imageView.layer.masksToBounds = true
		imageView.clipsToBounds = true
		imageView.autoHideWithTap()
		return imageView
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Hello, World!"
		label.font = .systemFont(ofSize: 20, weight: .bold)
		label.textColor = .label
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = .green
		label.autoHideWithTap()
		return label
	}()
	
	private lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.text = "SwiftUI Demo"
		label.font = .systemFont(ofSize: 18, weight: .regular)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = .red
		label.autoHideWithTap()
		return label
	}()
	
	private lazy var attributeLabel: PaddedLabel = {
		let label = PaddedLabel(padding: UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6))
		label.text = "Sponsored"
		label.font = .systemFont(ofSize: 14, weight: .semibold)
		label.textColor = .systemBlue
		label.translatesAutoresizingMaskIntoConstraints = false
		label.layer.cornerRadius = 5
		label.layer.masksToBounds = true
		label.layer.borderWidth = 2.0
		label.layer.borderColor = UIColor.systemBlue.cgColor
		label.autoHideWithTap()
		return label
	}()
	
	private lazy var bodyLabel: UILabel = {
		let label = UILabel()
		label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
		label.numberOfLines = 0
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = .systemPurple
		label.autoHideWithTap()
		return label
	}()
	
	private lazy var labelStack: AutoHidingStackView = {
		let stackView = AutoHidingStackView(arrangedSubviews: [titleLabel, sponsorStack, bodyLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 8
		stackView.alignment = .leading
		stackView.distribution = .fill
		stackView.backgroundColor = .systemYellow
		return stackView
	}()
	
	private lazy var sponsorStack: AutoHidingStackView = {
		let stackView = AutoHidingStackView(arrangedSubviews: [attributeLabel, subtitleLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.spacing = 24
		stackView.alignment = .center
		stackView.distribution = .fill
		stackView.backgroundColor = .systemCyan
		return stackView
	}()
	
	private lazy var stackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [imageView, labelStack])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.spacing = 8
		stackView.alignment = .center
		stackView.distribution = .fill
		stackView.layer.cornerRadius = 5
		stackView.layer.masksToBounds = true
		stackView.backgroundColor = .systemIndigo
		return stackView
	}()
	
	private func setupNavigationBar() {
		title = "UIStackView Demo"
		let minusButton = UIBarButtonItem(image: UIImage(systemName: "minus"), style: .done, target: self, action: #selector(minusButtonTapped))
		let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusButtonTapped))
		navigationItem.leftBarButtonItems = [minusButton, plusButton]
		
		let resetButton = UIBarButtonItem(image: UIImage(systemName: "arrow.counterclockwise"), style: .plain, target: self, action: #selector(resetButtonTapped))

		navigationItem.rightBarButtonItem = resetButton
	}
	
	private func setupViews() {
		view.backgroundColor = .systemGray3
		
		allSubviews.append(imageView)
		allSubviews.append(titleLabel)
		allSubviews.append(subtitleLabel)
		allSubviews.append(bodyLabel)
		allSubviews.append(attributeLabel)
		
		views = [imageView, titleLabel, subtitleLabel, bodyLabel, attributeLabel]
		
		view.addSubview(stackView)
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			imageView.widthAnchor.constraint(equalToConstant: 50),
			imageView.heightAnchor.constraint(equalToConstant: 50),
			
			stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
		])
	}
	
	@objc
	private func plusButtonTapped() {
		UIView.animate(withDuration: 0.3) {
			if let first = self.reserveSubviews.first {
				first.isHidden = false
				self.reserveSubviews.removeFirst()
				self.allSubviews.append(first)
			}
		}
	}
	
	@objc
	private func resetButtonTapped() {
		print("Subviews count: \(views.count)")
		UIView.animate(withDuration: 0.3) {
			for subview in self.views {
				subview.isHidden = false
			}
		}
	}
	
	@objc
	private func minusButtonTapped() {
		UIView.animate(withDuration: 0.3) {
			if let first = self.allSubviews.first {
				first.isHidden = true
				self.allSubviews.removeFirst()
				self.reserveSubviews.append(first)
			}
		}
	}
}

struct UIDemoViewController_Previews: PreviewProvider {
	static var previews: some View {
		UIViewControllerPreview {
			UINavigationController(rootViewController: UIDemoViewController())
		}
	}
}

extension UIView {
	func autoHideWithTap() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		self.addGestureRecognizer(tapGesture)
		self.isUserInteractionEnabled = true
	}
	
	@objc private func handleTap() {
		UIView.animate(withDuration: 0.3) {
			self.isHidden = true
		}
	}
}
