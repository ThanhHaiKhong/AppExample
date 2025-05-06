//
//  VerticalSlider.swift
//  Example
//
//  Created by Thanh Hai Khong on 25/4/25.
//

import UIKit

public class VerticalSlider: UIStackView {
    
    public var onValueChanged: ((Int, Float) -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - SetupViews
    
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
    
    private func setup() {
        axis = .vertical
        distribution = .fill
        spacing = 8
        alignment = .center
        layer.masksToBounds = true
        
        addArrangedSubview(slider)
        addArrangedSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            slider.widthAnchor.constraint(equalTo: heightAnchor, constant: -30),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    // MARK: - Actions
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        let value = sender.value
        onValueChanged?(sender.tag, value)
    }
}
