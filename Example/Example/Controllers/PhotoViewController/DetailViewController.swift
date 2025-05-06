//
//  DetailViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 12/3/25.
//

import UIConstants
import UIKit
import Hero
import Photos

class DetailViewController: UIViewController {
    
    private let asset: PHAsset
    
    public init(asset: PHAsset) {
        self.asset = asset
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupGestures()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.Padding.horizontal),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.Padding.horizontal),
            
            dismissButton.widthAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            dismissButton.heightAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            
            scaleButton.widthAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            scaleButton.heightAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
        ])
    }
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [scaleButton, UIView(), dismissButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = UIConstants.Spacing.inner
        return stackView
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "xmark", withConfiguration: symbolConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(dismissButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var scaleButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: symbolConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var symbolConfig: UIImage.SymbolConfiguration = {
        return UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
    }()
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(headerStackView)
    }
    
    private func configureUI() {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        let thumbnailSize = CGSize(width: view.frame.width * UIScreen.main.scale,
                                   height: view.frame.height * UIScreen.main.scale)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            print("🚦 LOADING_IMAGE on Thread: \(DispatchQueue.currentLabel)")
            guard let `self` = self else {
                return
            }
            
            PHImageManager.default().requestImage(for: self.asset,
                                                  targetSize: thumbnailSize,
                                                  contentMode: .aspectFill,
                                                  options: options) {  image, _ in
                guard let image = image else {
                    return
                }
                
                DispatchQueue.main.async {
                    print("🚦 UPDATE_IMAGE on Thread: \(DispatchQueue.currentLabel)")
                    self.imageView.image = image
                }
            }
        }
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
}

extension DetailViewController {
    
    @objc func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            dismiss(animated: true, completion: nil)
            
        case .changed:
            Hero.shared.update(translation.y / view.bounds.height)
            
        default:
            let velocity = gesture.velocity(in: view)
            if ((translation.y + velocity.y) / view.bounds.height) > 0.5 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
    }
}

/*
 let transition = CATransition()
 transition.duration = 0.25
 transition.type = .fade
 transition.subtype = .fromLeft
 
 self.imageView.layer.add(transition, forKey: kCATransition)
 // CATransition chỉ ảnh hưởng đến việc hiển thị (render tree), chứ không thêm layer mới vào imageView.layer (layer tree).
 // Nếu đã có một transition khác với cùng key (kCATransition), nó sẽ bị ghi đè bởi transition mới, không tạo thêm layer dư thừa.
 */
