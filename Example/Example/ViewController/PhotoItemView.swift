//
//  PhotoItemView.swift
//  Example
//
//  Created by Thanh Hai Khong on 12/3/25.
//

import UIKit
import Photos

public class PhotoItemView: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    public static let identifier = "reusePhotoItemView"
    public var representedAssetIdentifier: String!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    public lazy var livePhotoBadgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    public lazy var videoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "video.fill", withConfiguration: imageConfiguration)
        imageView.tintColor = .white
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    public lazy var selectButton: UIButton = {
        let button = UIButton()
        let normalImage = UIImage(systemName: "square", withConfiguration: imageConfiguration)
        let selectedImage = UIImage(systemName: "checkmark.square.fill", withConfiguration: imageConfiguration)
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.tintColor = .systemGreen
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var imageConfiguration: UIImage.SymbolConfiguration = {
        return UIImage.SymbolConfiguration(pointSize: 19, weight: .semibold)
    }()
    
    private func setupViews() {
        addSubview(imageView)
        addSubview(livePhotoBadgeImageView)
        addSubview(videoImageView)
        addSubview(selectButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            livePhotoBadgeImageView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            livePhotoBadgeImageView.topAnchor.constraint(equalTo: imageView.topAnchor),
            
            videoImageView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 3.5),
            videoImageView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 3.5),
            
            selectButton.topAnchor.constraint(equalTo: topAnchor, constant: 5.0),
            selectButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5.0),
        ])
    }
    
    public func configureUI() {
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [representedAssetIdentifier], options: nil).firstObject else {
            return
        }
        
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: PHImageManagerMaximumSize,
                                              contentMode: .aspectFill,
                                              options: nil) { [weak self] image, _ in
            guard let self = self, let image = image else {
                return
            }
            
            DispatchQueue.main.async {
                // Animation for image change
                UIView.transition(with: self.imageView,
                                  duration: 0.25,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.imageView.image = image
                }, completion: nil)
            }
        }
    }
    
    func animateSelection(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.1,  // Giảm thời gian để phản hồi nhanh hơn
            delay: 0,
            usingSpringWithDamping: 0.6,  // Tăng damping để tránh bật lại quá mạnh
            initialSpringVelocity: 0.5,
            options: [.allowUserInteraction],
            animations: {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                self.alpha = 0.85  // Thêm hiệu ứng fade-out nhẹ
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    usingSpringWithDamping: 0.8,  // Giảm damping để trở lại mượt hơn
                    initialSpringVelocity: 0.3,
                    options: [.allowUserInteraction],
                    animations: {
                        self.transform = .identity
                        self.alpha = 1.0  // Fade-in trở lại
                    },
                    completion: { _ in completion?() }
                )
            }
        )
    }
}
