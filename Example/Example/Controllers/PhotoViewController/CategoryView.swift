//
//  CategoryView.swift
//  Example
//
//  Created by Thanh Hai Khong on 19/3/25.
//

import PhotosClient
import UIConstants
import UIKit

protocol CategoryViewDelegate: AnyObject {
    func categoryView(_ view: CategoryView, didSelect category: PhotosClient.Category)
}

class CategoryView: UIView {
    
    weak var delegate: CategoryViewDelegate?
    private var currentCategory: PhotosClient.Category = .all {
        didSet {
            for view in stackView.arrangedSubviews {
                guard let button = view as? UIButton,
                      let identifier = button.accessibilityIdentifier,
                      let category = PhotosClient.Category(rawValue: identifier)
                else { continue }

                let newColor = category == currentCategory ? category.activeColor : .gray

                if button.tintColor != newColor {
                    UIView.animate(withDuration: 0.25) {
                        button.tintColor = newColor
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: UIConstants.Spacing.inner),
            stackView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor, constant: -UIConstants.Spacing.inner),
            stackView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
        ])
    }
    
    // MARK: - Views
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var visualEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: - SetupViews
    
    private func setupViews() {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        
        for category in PhotosClient.Category.allCases {
            let button = UIButton()
            button.accessibilityIdentifier = category.rawValue
            button.tintColor = category == currentCategory ? category.activeColor : .gray
            button.setImage(UIImage(systemName: category.systemName, withConfiguration: symbolConfig), for: .normal)
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(button)
        }
        
        visualEffectView.contentView.addSubview(stackView)
        addSubview(visualEffectView)
    }
    
    // MARK: - Actions
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        guard let category = PhotosClient.Category(rawValue: sender.accessibilityIdentifier ?? "") else { return }
        currentCategory = category
        delegate?.categoryView(self, didSelect: category)
    }
}
