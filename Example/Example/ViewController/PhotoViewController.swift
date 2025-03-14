//
//  PhotoViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 12/3/25.
//

import UIKit
import Photos
import PhotosUI
import Hero

public class PhotoViewController: UIViewController {
    
    private let imageManager = PHCachingImageManager()
    private let imageCache = NSCache<NSString, UIImage>()
    
    private var fetchResult = PHFetchResult<PHAsset>()
    private var dataSource: UICollectionViewDiffableDataSource<Int, PHAsset>! = nil
    private var selectedIndexPath: IndexPath?
    private var previousPreheatRect = CGRect.zero
    private var thumbnailSize = CGSize(width: 100, height: 100)
    private var isSelecting = false
    private var isDataLoaded = false
    private var selectedPhoto: PhotoItemView? {
        guard let selectedIndexPath = selectedIndexPath,
              let selectedCell = collectionView.cellForItem(at: selectedIndexPath) as? PhotoItemView else {
            return nil
        }
        return selectedCell
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.configureDataSource()
        
        self.resetCachedAssets()
        
        if !isDataLoaded {
            fetchAssets()
            isDataLoaded = true
        }
        
        PHPhotoLibrary.shared().register(self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCachedAssets()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            toggleSelectionButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            toggleSelectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.register(PhotoItemView.self, forCellWithReuseIdentifier: PhotoItemView.identifier)
        return collectionView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "All Photos"
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredRoundedFont(forTextStyle: .title2, weight: .heavy)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredRoundedFont(forTextStyle: .headline, weight: .semibold)
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredRoundedFont(forTextStyle: .headline, weight: .semibold)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var toggleSelectionButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .systemGreen
        configuration.buttonSize = .medium
        configuration.background.backgroundColor = .systemGray5
        
        var textAttributes = AttributeContainer()
        textAttributes.font = .preferredRoundedFont(forTextStyle: .headline, weight: .semibold)
        configuration.attributedTitle = AttributedString("Select", attributes: textAttributes)
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(toggleSelectionTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
}

// MARK: - Supporting Methods

extension PhotoViewController {
    
    private func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(stackView)
        view.addSubview(toggleSelectionButton)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let innerSpacing: CGFloat = 2.0
        let itemCount = 4

        let layout = UICollectionViewCompositionalLayout { (_, layoutEnvironment) -> NSCollectionLayoutSection? in
            let itemWidthFraction = 1.0 / CGFloat(itemCount)

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(itemWidthFraction),
                heightDimension: .fractionalHeight(1.0)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(itemWidthFraction)
            )

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: itemCount)
            group.interItemSpacing = .fixed(innerSpacing)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: innerSpacing, leading: 0, bottom: innerSpacing, trailing: 0)
            section.interGroupSpacing = innerSpacing

            return section
        }

        return layout
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, PHAsset>(collectionView: collectionView) { [weak self] collectionView, indexPath, asset in
            guard let self = self,
                  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoItemView.identifier, for: indexPath) as? PhotoItemView else {
                return UICollectionViewCell()
            }
            
            self.configureCell(cell, with: asset)

            return cell
        }
    }

    private func configureCell(_ cell: PhotoItemView, with asset: PHAsset) {
        cell.selectButton.isHidden = !collectionView.isEditing
        cell.imageView.alpha = cell.isSelected ? 0.75 : 1.0
        cell.selectButton.isSelected = cell.isSelected
        cell.representedAssetIdentifier = asset.localIdentifier

        if asset.mediaSubtypes.contains(.photoLive) {
            cell.livePhotoBadgeImageView.image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
            cell.livePhotoBadgeImageView.isHidden = false
        } else {
            cell.livePhotoBadgeImageView.isHidden = true
        }
        
        cell.videoImageView.isHidden = asset.mediaType != .video

        let cacheKey = asset.localIdentifier as NSString

        if let cachedImage = imageCache.object(forKey: cacheKey) {
            cell.imageView.image = cachedImage
            return
        }

        let thumbnailSize = CGSize(width: cell.frame.width * UIScreen.main.scale,
                                   height: cell.frame.height * UIScreen.main.scale)
        
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            print("⚙️ Đang tải ảnh: \(progress * 100)%")
        }

        imageManager.requestImage(for: asset,
                                  targetSize: thumbnailSize,
                                  contentMode: .aspectFill,
                                  options: options) { [weak self, weak cell] image, _ in
            guard let self = self, let cell = cell, cell.representedAssetIdentifier == asset.localIdentifier, let image = image else {
                return
            }
            
            self.imageCache.setObject(image, forKey: cacheKey)

            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }
    }
    
    private func fetchAssets() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        let assets = fetchResult.objects(at: IndexSet(0..<fetchResult.count))
        
        let videoCount = assets.filter { $0.mediaType == .video }.count
        let photoCount = assets.count - videoCount
        let photoString = photoCount == 1 ? "Photo" : "Photos"
        let videoString = videoCount == 1 ? "Video" : "Videos"
        
        DispatchQueue.main.async {
            self.subtitleLabel.text = "\(photoCount) \(photoString), \(videoCount) \(videoString)"
            
            var snapshot = NSDiffableDataSourceSnapshot<Int, PHAsset>()
            snapshot.appendSections([0])
            snapshot.appendItems(assets)
            
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    private func updateCachedAssets() {
        guard isViewLoaded, view.window != nil else { return }
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        let visibleAssets = visibleIndexPaths.compactMap { fetchResult.object(at: $0.item) }
        
        imageManager.startCachingImages(for: visibleAssets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        previousPreheatRect = collectionView.bounds
    }
    
    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            let combined = old.union(new)
            let added = new.intersection(combined).isNull ? [new] : []
            let removed = old.intersection(combined).isNull ? [old] : []
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    private func fetchAssets(in collection: PHAssetCollection? = nil, sort sortDescriptor: NSSortDescriptor? = nil) -> [PHAsset] {
        let fetchOptions = PHFetchOptions()
        if let sortDescriptor = sortDescriptor {
            fetchOptions.sortDescriptors = [sortDescriptor]
        }
        
        let fetchResult: PHFetchResult<PHAsset>
        if let collection = collection {
            fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        } else {
            fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        }
        
        return fetchResult.objects(at: IndexSet(0..<fetchResult.count))
    }
}

// MARK: - Actions

extension PhotoViewController {
    
    @objc func selectButtonTapped(_ sender: UIButton) {
        self.isEditing = true
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        self.isEditing = false
    }
    
    @objc private func toggleSelectionTapped(_ sender: UIButton) {
        isSelecting.toggle()
        
        var textAttributes = AttributeContainer()
        textAttributes.font = .preferredRoundedFont(forTextStyle: .headline, weight: .semibold)
        
        var updatedConfig = sender.configuration
        updatedConfig?.attributedTitle = AttributedString(isSelecting ? "Cancel" : "Select", attributes: textAttributes)
        
        sender.configuration = updatedConfig
        updateSelectionMode(isSelecting)
    }
    
    private func updateSelectionMode(_ selecting: Bool) {
        collectionView.allowsMultipleSelection = selecting
        collectionView.allowsMultipleSelectionDuringEditing = selecting
        collectionView.isEditing = selecting
        
        if !selecting {
            collectionView.indexPathsForSelectedItems?.forEach { indexPath in
                collectionView.deselectItem(at: indexPath, animated: true)
            }
        }
        
        collectionView.reloadData()
    }
}

// MARK: - UIScrollViewDelegate

extension PhotoViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
}

// MARK: - UICollectionViewDelegate

extension PhotoViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoItemView, let asset = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        cell.animateSelection { [weak self] in
            guard let `self` = self else {
                return
            }
            
            if self.isSelecting {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                
                guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.countLabel.text = selectedIndexPaths.count <= 1 ? "Select Item" : "\(selectedIndexPaths.count) Items Selected"
                    cell.selectButton.isSelected = true
                    cell.imageView.alpha = 0.75
                }
            } else {
                cell.hero.id = asset.localIdentifier
                cell.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
                
                let detailViewController = DetailViewController(asset: asset)
                print("🚦 INITIALIZE_IMAGE on Thread: \(DispatchQueue.currentLabel)")
                detailViewController.imageView.image = cell.imageView.image
                detailViewController.modalPresentationStyle = .fullScreen
                detailViewController.hero.isEnabled = true
                detailViewController.hero.modalAnimationType = .zoomOut
                detailViewController.imageView.hero.id = asset.localIdentifier
                self.present(detailViewController, animated: true)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.isEditing {
            collectionView.deselectItem(at: indexPath, animated: true)
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoItemView,
                  let selectedIndexPaths = collectionView.indexPathsForSelectedItems
            else {
                return
            }

            self.countLabel.text = selectedIndexPaths.count <= 1 ? "Select Item" : "\(selectedIndexPaths.count) Items Selected"
            cell.selectButton.isSelected = false
            cell.imageView.alpha = 1.0
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension PhotoViewController: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard changeInstance.changeDetails(for: fetchResult) != nil else { return }
        
        DispatchQueue.global(qos: .background).async {
            let updatedFetchResult = PHAsset.fetchAssets(with: .image, options: nil)

            DispatchQueue.main.async {
                self.fetchResult = updatedFetchResult
                self.collectionView.reloadData()
            }
        }
    }
}
