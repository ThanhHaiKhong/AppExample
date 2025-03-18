//
//  PhotoViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 12/3/25.
//

import ComposableArchitecture
import RemoteConfigClient
import UIComponents
import Kingfisher
import PhotosUI
import SwiftUI
import Photos
import UIKit
import Hero

public class PhotoViewController: UIViewController {
    public enum Section: Int, Sendable {
        case editorChoices
        case allPhotos
    }
    
    public enum Item: Hashable, Sendable {
        case editorChoice(StoreOf<EditorChoiceCard>)
        case photo(StoreOf<PhotoCard>)
    }

    @UIBindable private var store: StoreOf<PhotoList>
    
    private let imageManager = PHCachingImageManager()
    private let imageCache = NSCache<NSString, UIImage>()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    private var thumbnailSize = CGSize(width: 100, height: 100)
    
    public init(store: StoreOf<PhotoList>) {
        self.store = store
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        let editorChoiceCellRegistration = UICollectionView.CellRegistration<EditorChoiceItemView, StoreOf<EditorChoiceCard>> { [weak self] cell, _, store in
            guard let `self` = self else {
                return
            }
            
            configureCell(cell, with: store)
        }
        
        let photoCellRegistration = UICollectionView.CellRegistration<PhotoItemView, StoreOf<PhotoCard>> { [weak self] cell, indexPath, store in
            guard let `self` = self else {
                return
            }
            
            configureCell(cell, with: store)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case let .photo(asset):
                return collectionView.dequeueConfiguredReusableCell(using: photoCellRegistration, for: indexPath, item: asset)
                
            case let .editorChoice(editorChoice):
                return collectionView.dequeueConfiguredReusableCell(using: editorChoiceCellRegistration, for: indexPath, item: editorChoice)
            }
        }
        
        observe { [weak self] in
            guard let `self` = self else {
                return
            }
            
            print("🚦 OBSERVE on Thread: \(DispatchQueue.currentLabel) - Photos: \(store.photos.count) - EditorChoices: \(store.editorChoices.count)")
            countLabel.text = "\(store.photos.count) photos"
            
            measureExecutionTime("APPLY_SNAPSHOT") { completion in
                self.dataSource.apply(.init(store: self.store), animatingDifferences: true)
                completion()
            }
        }
        
        present(item: $store.scope(state: \.showSubscriptions, action: \.showSubscriptions)) { store in
            self.premiumButton.hero.id = "asset.localIdentifier"
            self.premiumButton.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
            
            let hostingVC = UIHostingController(rootView: SubscriptionView(store: store))
            hostingVC.modalPresentationStyle = .fullScreen
            hostingVC.hero.isEnabled = true
            hostingVC.hero.modalAnimationType = .zoomOut
            hostingVC.view.hero.id = "asset.localIdentifier"
            
            return hostingVC
        }
        
        store.send(.onDidLoad)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupConstraints()
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(EditorChoiceItemView.self, forCellWithReuseIdentifier: EditorChoiceItemView.identifier)
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
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredRoundedFont(forTextStyle: .headline, weight: .semibold)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var fileButton: UIButton = {
        let button = UIButton()
        let normalImage = UIImage(systemName: "folder.fill", withConfiguration: imageConfiguration)
        button.setImage(normalImage, for: .normal)
        button.layer.cornerRadius = 17.0
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.addTarget(self, action: #selector(fileButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton()
        let normalImage = UIImage(systemName: "camera.fill", withConfiguration: imageConfiguration)
        button.setImage(normalImage, for: .normal)
        button.layer.cornerRadius = 17.0
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.addTarget(self, action: #selector(cameraButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var premiumButton: UIButton = {
        let button = UIButton()
        let normalImage = UIImage(systemName: "crown.fill", withConfiguration: imageConfiguration)
        button.setImage(normalImage, for: .normal)
        button.layer.cornerRadius = 17.0
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.addTarget(self, action: #selector(premiumButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        let normalImage = UIImage(systemName: "gearshape.fill", withConfiguration: imageConfiguration)
        button.setImage(normalImage, for: .normal)
        button.layer.cornerRadius = 17.0
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.addTarget(self, action: #selector(settingsButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fileButton, cameraButton, UIView(), premiumButton, settingsButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var footerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stackView, UIView(), toggleSelectionButton, sortButton, changeLayoutButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, countLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var toggleSelectionButton: UIButton = {
        var configuration = UIButton.Configuration.borderedProminent()
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .white
        configuration.buttonSize = .medium
        configuration.background.backgroundColor = .systemGreen
        
        var textAttributes = AttributeContainer()
        textAttributes.font = .preferredRoundedFont(forTextStyle: .subheadline, weight: .semibold)
        configuration.attributedTitle = AttributedString("Select", attributes: textAttributes)
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(toggleSelectionTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        let normalImage = UIImage(systemName: "line.3.horizontal.decrease", withConfiguration: imageConfiguration)
        button.setImage(normalImage, for: .normal)
        button.layer.cornerRadius = 17.0
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.addTarget(self, action: #selector(sortButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var changeLayoutButton: UIButton = {
        let button = UIButton()
        let normalImage = UIImage(systemName: "square.grid.3x3.square", withConfiguration: imageConfiguration)
        button.setImage(normalImage, for: .normal)
        button.layer.cornerRadius = 17.0
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.addTarget(self, action: #selector(changeLayoutButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var imageConfiguration: UIImage.SymbolConfiguration = {
        return .init(pointSize: 15, weight: .semibold)
    }()
}

// MARK: - Supporting Methods

extension PhotoViewController {
    
    private func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(headerStackView)
        view.addSubview(footerStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            fileButton.widthAnchor.constraint(equalToConstant: 34),
            fileButton.heightAnchor.constraint(equalToConstant: 34),
            
            cameraButton.widthAnchor.constraint(equalToConstant: 34),
            cameraButton.heightAnchor.constraint(equalToConstant: 34),
            
            premiumButton.widthAnchor.constraint(equalToConstant: 34),
            premiumButton.heightAnchor.constraint(equalToConstant: 34),
            
            settingsButton.widthAnchor.constraint(equalToConstant: 34),
            settingsButton.heightAnchor.constraint(equalToConstant: 34),
            
            footerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            footerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            toggleSelectionButton.heightAnchor.constraint(equalToConstant: 34),
            
            sortButton.widthAnchor.constraint(equalToConstant: 34),
            sortButton.heightAnchor.constraint(equalToConstant: 34),
            
            changeLayoutButton.widthAnchor.constraint(equalToConstant: 34),
            changeLayoutButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = .zero
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let `self` = self,
                  let section = Section(rawValue: sectionIndex) else {
                return nil
            }
            
            switch section {
            case .editorChoices:
                return editorChoiceLayoutSection(layoutEnvironment)
                
            case .allPhotos:
                return photoLayoutSection()
            }
        }, configuration: configuration)
        
        return layout
    }
    
    private func editorChoiceLayoutSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let isRegular = layoutEnvironment.traitCollection.horizontalSizeClass == .regular
        let contentSize = layoutEnvironment.container.contentSize
        let innerSpacing: CGFloat = 12.0
        let edgeInsets = NSDirectionalEdgeInsets(top: innerSpacing + 34.0, leading: 20, bottom: innerSpacing, trailing: 20)
        let itemCount = isRegular ? 2 : 1
        let itemWidthFactor: CGFloat = 1.4

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let widthGroup = (contentSize.width - edgeInsets.leading - edgeInsets.trailing - CGFloat(itemCount - 1) * innerSpacing) / CGFloat(itemCount)
        let heightGroup = widthGroup / itemWidthFactor
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(widthGroup),
            heightDimension: .absolute(heightGroup)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(innerSpacing)

        let layoutSection = NSCollectionLayoutSection(group: group)
        layoutSection.contentInsets = edgeInsets
        layoutSection.interGroupSpacing = innerSpacing
        layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

        return layoutSection
    }
    
    private func photoLayoutSection() -> NSCollectionLayoutSection {
        let innerSpacing: CGFloat = 2.0
        let itemCount = 4
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

        let layoutSection = NSCollectionLayoutSection(group: group)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: innerSpacing, leading: 0, bottom: innerSpacing, trailing: 0)
        layoutSection.interGroupSpacing = innerSpacing

        return layoutSection
    }
    
    private func configureCell(_ cell: EditorChoiceItemView, with store: StoreOf<EditorChoiceCard>) {
        DispatchQueue.main.async {
            if let url = store.item.artworkURL {
                cell.backgroundImageView.kf.setImage(
                    with: url,
                    options: [
                        .loadDiskFileSynchronously,
                        .cacheOriginalImage,
                        .transition(.fade(0.25)),
                    ]
                )
            }
            
            if let url = store.item.miniIconURL {
                cell.iconImageView.kf.setImage(
                    with: url,
                    options: [
                        .loadDiskFileSynchronously,
                        .cacheOriginalImage,
                        .transition(.fade(0.25)),
                    ]
                )
            }
            
            cell.titleLabel.text = store.item.title
            cell.subtitleLabel.text = store.item.description
        }
    }

    private func configureCell(_ cell: PhotoItemView, with store: StoreOf<PhotoCard>) {
        cell.selectButton.isHidden = !collectionView.isEditing
        cell.imageView.alpha = cell.isSelected ? 0.75 : 1.0
        cell.selectButton.isSelected = cell.isSelected
        cell.representedAssetIdentifier = store.asset.localIdentifier

        if store.asset.mediaSubtypes.contains(.photoLive) {
            cell.livePhotoBadgeImageView.image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
            cell.livePhotoBadgeImageView.isHidden = false
        } else {
            cell.livePhotoBadgeImageView.isHidden = true
        }
        
        cell.videoImageView.isHidden = store.asset.mediaType != .video

        let cacheKey = store.asset.localIdentifier as NSString

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
        
        imageManager.requestImage(for: store.asset,
                                  targetSize: thumbnailSize,
                                  contentMode: .aspectFill,
                                  options: options) { [weak self, weak cell] image, _ in
            guard let self = self, let cell = cell, cell.representedAssetIdentifier == store.asset.localIdentifier, let image = image else {
                return
            }
            
            self.imageCache.setObject(image, forKey: cacheKey)

            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }
    }
}

// MARK: - Actions

extension PhotoViewController {
    
    @objc private func fileButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func cameraButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func premiumButtonTapped(_ sender: UIButton) {
        store.send(.premiumButtonTapped)
    }
    
    @objc private func settingsButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        self.isEditing = false
    }
    
    @objc private func sortButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func changeLayoutButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func toggleSelectionTapped(_ sender: UIButton) {
        store.send(.toggleSectionButtonTapped)
        
        var textAttributes = AttributeContainer()
        textAttributes.font = .preferredRoundedFont(forTextStyle: .subheadline, weight: .semibold)
        
        var updatedConfig = sender.configuration
        updatedConfig?.attributedTitle = AttributedString(store.isSelecting ? "Cancel" : "Select", attributes: textAttributes)
        
        sender.configuration = updatedConfig
        updateSelectionMode(store.isSelecting)
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

// MARK: - UICollectionViewDelegate

extension PhotoViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoItemView, let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        cell.animateSelection { [weak self] in
            guard let `self` = self else {
                return
            }
            
            if self.store.isSelecting {
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
                switch item {
                case let .photo(store):
                    cell.hero.id = store.asset.localIdentifier
                    cell.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
                    
                    let detailViewController = DetailViewController(asset: store.asset)
                    print("🚦 INITIALIZE_IMAGE on Thread: \(DispatchQueue.currentLabel)")
                    detailViewController.imageView.image = cell.imageView.image
                    detailViewController.modalPresentationStyle = .fullScreen
                    detailViewController.hero.isEnabled = true
                    detailViewController.hero.modalAnimationType = .zoomOut
                    detailViewController.imageView.hero.id = store.asset.localIdentifier
                    self.present(detailViewController, animated: true)
                    
                case .editorChoice:
                    break
                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if store.isSelecting {
            collectionView.deselectItem(at: indexPath, animated: true)
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoItemView,
                  let selectedIndexPaths = collectionView.indexPathsForSelectedItems
            else {
                return
            }
            
            DispatchQueue.main.async {
                self.countLabel.text = selectedIndexPaths.count <= 1 ? "Select Item" : "\(selectedIndexPaths.count) Items Selected"
                cell.selectButton.isSelected = false
                cell.imageView.alpha = 1.0
            }
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension PhotoViewController: UICollectionViewDataSourcePrefetching {
        
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let photoIndexPaths = indexPaths.filter { $0.section == 1 }
        let assets = photoIndexPaths.compactMap { store.photos[$0.item].asset }
        imageManager.startCachingImages(for: assets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let photoIndexPaths = indexPaths.filter { $0.section == 1 }
        let assets = photoIndexPaths.compactMap { store.photos[$0.item].asset }
        imageManager.stopCachingImages(for: assets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
    }
}

extension NSDiffableDataSourceSnapshot where SectionIdentifierType == PhotoViewController.Section, ItemIdentifierType == PhotoViewController.Item {
    init(store: StoreOf<PhotoList>) {
        self.init()
        
        appendSections([.editorChoices])
        appendSections([.allPhotos])
         
        if !store.editorChoices.isEmpty && !store.isSelecting {
            var editorChoiceStores: [StoreOf<EditorChoiceCard>] = []
            for editorChoice in store.editorChoices {
                let id = editorChoice.id
                if let store = store.scope(state: \.editorChoices[id: id], action: \.editorChoices[id: id]) {
                    editorChoiceStores.append(store)
                }
            }
            appendItems(editorChoiceStores.map { .editorChoice($0) }, toSection: .editorChoices)
        }
        
        if !store.photos.isEmpty {
            var photoStores: [StoreOf<PhotoCard>] = []
            for photo in store.photos {
                let id = photo.id
                if let store = store.scope(state: \.photos[id: id], action: \.photos[id: id]) {
                    photoStores.append(store)
                }
            }
            appendItems(photoStores.map { .photo($0) }, toSection: .allPhotos)
        }
    }
    
    mutating func updateItems(_ items: [ItemIdentifierType], toSection section: SectionIdentifierType) {
        appendItems(items, toSection: section)
    }
}

func measureExecutionTime(_ label: String, block: (@escaping () -> Void) -> Void) {
    let start = DispatchTime.now()
    let group = DispatchGroup()
    group.enter()
    
    block {
        group.leave()
    }
    
    group.wait()
    let end = DispatchTime.now()
    let elapsed = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
    print("⏳ \(label.uppercased()) executed on Thread: \(DispatchQueue.currentLabel) in \(elapsed) seconds")
}
