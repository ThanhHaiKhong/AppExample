//
//  DetailViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 12/3/25.
//

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
        setupGesture()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
    }
    
    private func configureUI() {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            print("🚦 LOAD_IMAGE on Thread: \(DispatchQueue.currentLabel)")
            guard let `self` = self else {
                return
            }
            
            PHImageManager.default().requestImage(for: self.asset,
                                                  targetSize: PHImageManagerMaximumSize,
                                                  contentMode: .aspectFill,
                                                  options: options) {  image, _ in
                guard let image = image else {
                    return
                }
                
                DispatchQueue.main.async {
                    print("🚦 UPDATE_IMAGE on Thread: \(DispatchQueue.currentLabel)")
                    self.imageView.image = image
                    /*
                    let transition = CATransition()
                    transition.duration = 0.25
                    transition.type = .fade
                    transition.subtype = .fromLeft

                    self.imageView.layer.add(transition, forKey: kCATransition)
                    // CATransition chỉ ảnh hưởng đến việc hiển thị (render tree), chứ không thêm layer mới vào imageView.layer (layer tree).
                    // Nếu đã có một transition khác với cùng key (kCATransition), nó sẽ bị ghi đè bởi transition mới, không tạo thêm layer dư thừa.
                    */
                }
            }
        }
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDetail))
        view.addGestureRecognizer(tapGesture)
    }
}

extension DetailViewController {
    
    @objc func dismissDetail() {
        dismiss(animated: true)
    }
}

extension DispatchQueue {
    static var currentLabel: String {
        let name = __dispatch_queue_get_label(nil)
        if let label = String(cString: name, encoding: .utf8) {
            return label
        }
        return "Unknown"
    }
}
