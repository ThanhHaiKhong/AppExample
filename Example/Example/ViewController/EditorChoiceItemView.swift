//
//  EditorChoiceItemView.swift
//  Example
//
//  Created by Thanh Hai Khong on 17/3/25.
//

import UIKit

public class EditorChoiceItemView: UICollectionViewCell {
    
    public static let identifier = "reuseEditorChoiceItemView"
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()

        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        self.priceLabel.layer.cornerRadius = 13.0
        self.priceLabel.layer.masksToBounds = true
        
        self.iconImageView.layer.cornerRadius = 5
        self.iconImageView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            prominentGradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
            prominentGradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            prominentGradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            prominentGradientView.heightAnchor.constraint(equalToConstant: 60),
            
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.centerYAnchor.constraint(equalTo: prominentGradientView.centerYAnchor),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            priceLabel.widthAnchor.constraint(equalToConstant: 60),
            priceLabel.heightAnchor.constraint(equalToConstant: 26),
        ])
    }
    
    public lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .secondarySystemBackground
        
        return imageView
    }()
    
    public lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .systemBlue
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    public lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .systemBlue.withAlphaComponent(0.25)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    public lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.text = "FREE"
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleStackView, priceLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var prominentGradientView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var imageConfiguration: UIImage.SymbolConfiguration = {
        return UIImage.SymbolConfiguration(pointSize: 19, weight: .semibold)
    }()
    
    private func setupViews() {
        prominentGradientView.addSubview(stackView)
        addSubview(backgroundImageView)
        addSubview(prominentGradientView)
    }
}

class ProminentGradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let blurEffectView: UIVisualEffectView
    
    override init(frame: CGRect) {
        let blurEffect = UIBlurEffect(style: .dark)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .fill)
        blurEffectView = UIVisualEffectView(effect: vibrancyEffect)
        
        super.init(frame: frame)
//        setupGradient()
        setupBlur()
    }
    
    required init?(coder: NSCoder) {
        let blurEffect = UIBlurEffect(style: .systemThickMaterial)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .fill)
        blurEffectView = UIVisualEffectView(effect: vibrancyEffect)
        
        super.init(coder: coder)
//        setupGradient()
        setupBlur()
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupBlur() {
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        blurEffectView.frame = bounds
    }
}
