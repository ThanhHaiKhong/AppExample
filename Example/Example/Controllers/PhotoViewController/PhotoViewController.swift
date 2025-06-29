//
//  PhotoViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 12/3/25.
//

import ComposableArchitecture
import RemoteConfigClient
import PhotosClient
import TCAFeatureAction
import UIConstants
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
        case photo(PHAsset)
		case editorChoice(RemoteConfigClient.EditorChoice)
    }

    @UIBindable private var store: StoreOf<PhotoList>
    
    private let imageManager = PHCachingImageManager()
    private let imageCache = NSCache<NSString, UIImage>()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    private var thumbnailSize = CGSize(width: 100, height: 100)
    private var placeholderBottomConstraint: NSLayoutConstraint!
    
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
        setupConstraints()
        
		let editorChoiceCellRegistration = UICollectionView.CellRegistration<EditorChoiceItemView, RemoteConfigClient.EditorChoice> { [weak self] cell, _, editorChoice in
            guard let `self` = self else {
                return
            }
            
            configureCell(cell, with: editorChoice)
        }
        
        let photoCellRegistration = UICollectionView.CellRegistration<PhotoItemView, PHAsset> { [weak self] cell, indexPath, asset in
            guard let `self` = self else {
                return
            }
            
            configureCell(cell, with: asset)
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
            
            placeholderBottomConstraint.constant = -UIConstants.Padding.horizontal
            
            UIView.animate(withDuration: 0.3) {
                self.headerStackView.alpha = self.store.isSelecting ? 0 : 1
                self.categoryView.alpha = self.store.isSelecting ? 0 : 1
                
                if self.store.isSelecting {
                    self.titleLabel.text = "Select Photos"
                    self.countLabel.text = "No photos selected"
                } else {
                    self.titleLabel.text = self.store.currentCategory.rawValue
                    self.countLabel.text = self.store.photos.count <= 1 ? "1 photo" : "\(self.store.photos.count) photos"
                    self.nextButton.alpha = 0
                    self.warningContainerView.alpha = 0
                }
                
                self.view.layoutIfNeeded()
            }
            
            let angle: CGFloat = store.isAscendingOrder ? 0 : .pi

            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 1.0,
                           options: [.curveEaseInOut],
                           animations: {
                let rotation = CGAffineTransform(rotationAngle: angle)
                let scale = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.sortButton.transform = rotation.concatenating(scale)
            }) { _ in
                UIView.animate(withDuration: 0.25) {
                    self.sortButton.transform = CGAffineTransform(rotationAngle: angle)
                }
            }
        }
        
        observe { [weak self] in
            guard let `self` = self else {
                return
            }
            
            let isNowSelected = !store.isGridLayout
            changeLayoutButton.isSelected = isNowSelected
            let newLayout = store.isGridLayout ? createLayout() : createSpiralLayout()
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 1.0,
                           options: [.curveEaseInOut],
                           animations: {
                self.changeLayoutButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) { _ in
                UIView.animate(withDuration: 0.25) {
                    self.changeLayoutButton.transform = .identity
                    self.collectionView.setCollectionViewLayout(newLayout, animated: true)
                }
            }
        }
        
        observe { [weak self] in
            guard let `self` = self else {
                return
            }
            
            print("🚦 OBSERVE on Thread: \(DispatchQueue.currentLabel) - Photos: \(store.photos.count) - EditorChoices: \(store.editorChoices.count)")

            measureExecutionTime("APPLY_SNAPSHOT") { done in
                self.dataSource.apply(.init(store: self.store), animatingDifferences: true)
                done()
            }
        }
        
        present(item: $store.scope(state: \.showSubscriptions, action: \.showSubscriptions)) { store in
            self.premiumButton.hero.id = "asset.localIdentifier"
            self.premiumButton.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
            
            let hostingVC = CustomHostingController(store: store) { store in
                SubscriptionView(store: store)
            }
            hostingVC.modalPresentationStyle = .fullScreen
            hostingVC.hero.isEnabled = true
            hostingVC.hero.modalAnimationType = .zoomOut
            hostingVC.view.hero.id = "asset.localIdentifier"
            
            return hostingVC
        }
        
        present(item: $store.scope(state: \.showCard, action: \.showCard)) { store in
            let id: String = UUID().uuidString
            if let selectedItem = self.store.selectedItem, let cell = self.collectionView.cellForItem(at: selectedItem.indexPath) as? PhotoItemView {
                cell.hero.id = id
                cell.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
            }
            
            let hostingVC = CustomHostingController(store: store) { store in
                PhotoCardView(store: store)
            }
            hostingVC.modalPresentationStyle = .fullScreen
            hostingVC.hero.isEnabled = true
            hostingVC.hero.modalAnimationType = .zoomOut
            hostingVC.view.hero.id = id
            
            return hostingVC
        }
        
        store.send(.onDidLoad)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var warningSelectableLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredRoundedFont(forTextStyle: .subheadline, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Currently, we support processing up to 20 photos at a time. For the best experience, please deselect some to continue."
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var fileButton: UIButton = {
        let button = UIButton()
        let normalImage = UIImage(systemName: "folder.fill", withConfiguration: imageConfiguration)
        button.setImage(normalImage, for: .normal)
        button.layer.cornerRadius = UIConstants.Sizes.small / 2
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
        button.layer.cornerRadius = UIConstants.Sizes.small / 2
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
        button.layer.cornerRadius = UIConstants.Sizes.small / 2
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
        button.layer.cornerRadius = UIConstants.Sizes.small / 2
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
        let selectedImage = UIImage(systemName: "chevron.up.2", withConfiguration: imageConfiguration)
        button.setImage(normalImage, for: .normal)
        button.layer.cornerRadius = UIConstants.Sizes.small / 2
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.addTarget(self, action: #selector(sortButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .systemGreen
        configuration.title = "Next"
        configuration.image = UIImage(systemName: "chevron.forward.2")
        configuration.imagePadding = 5
        configuration.imagePlacement = .trailing
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            return outgoing
        }
        
        let button = UIButton(configuration: configuration)
        button.alpha = 0.0
        button.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var changeLayoutButton: UIButton = {
        let button = UIButton()
        let normalImage = UIImage(systemName: "rectangle.3.group", withConfiguration: imageConfiguration)
        let selectedImage = UIImage(systemName: "square.grid.2x2", withConfiguration: imageConfiguration)
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.layer.cornerRadius = UIConstants.Sizes.small / 2
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.addTarget(self, action: #selector(changeLayoutButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var imageConfiguration: UIImage.SymbolConfiguration = {
        return UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
    }()
    
    private lazy var categoryView: CategoryView = {
        let view = CategoryView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var placeholderView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var warningContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        view.alpha = 0.0
        view.backgroundColor = .systemYellow.withAlphaComponent(0.85)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var topGradientBlurView: GradientBlurView = {
        let view = GradientBlurView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var bottomGradientBlurView: GradientBlurView = {
        let view = GradientBlurView(reverse: true)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
}

// MARK: - Supporting Methods

extension PhotoViewController {
    
    private func setupViews() {
        placeholderView.contentView.addSubview(nextButton)
        warningContainerView.addSubview(warningSelectableLabel)
        view.addSubview(collectionView)
        view.addSubview(topGradientBlurView)
        view.addSubview(headerStackView)
        view.addSubview(placeholderView)
        view.addSubview(warningContainerView)
        view.addSubview(categoryView)
        view.addSubview(bottomGradientBlurView)
        view.addSubview(footerStackView)
    }
    
    private func setupConstraints() {
        placeholderBottomConstraint = placeholderView.bottomAnchor.constraint(equalTo: footerStackView.topAnchor, constant: -UIConstants.Padding.horizontal)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            topGradientBlurView.topAnchor.constraint(equalTo: view.topAnchor),
            topGradientBlurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topGradientBlurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topGradientBlurView.bottomAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: UIConstants.Padding.horizontal),
            
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.Padding.horizontal),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.Padding.horizontal),
            
            categoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.Padding.horizontal),
            categoryView.bottomAnchor.constraint(equalTo: placeholderView.topAnchor, constant: -UIConstants.Padding.horizontal),
            categoryView.widthAnchor.constraint(equalToConstant: 40),
            
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.Padding.horizontal),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.Padding.horizontal),
            placeholderBottomConstraint,
            placeholderView.heightAnchor.constraint(equalToConstant: 50),
            
            nextButton.topAnchor.constraint(equalTo: placeholderView.contentView.topAnchor),
            nextButton.leadingAnchor.constraint(equalTo: placeholderView.contentView.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: placeholderView.contentView.trailingAnchor),
            nextButton.bottomAnchor.constraint(equalTo: placeholderView.contentView.bottomAnchor),
            
            warningContainerView.topAnchor.constraint(equalTo: placeholderView.bottomAnchor, constant: UIConstants.Spacing.inner),
            warningContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.Padding.horizontal),
            warningContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.Padding.horizontal),
            warningContainerView.heightAnchor.constraint(equalToConstant: 70),
            
            warningSelectableLabel.topAnchor.constraint(equalTo: warningContainerView.topAnchor, constant: 8),
            warningSelectableLabel.leadingAnchor.constraint(equalTo: warningContainerView.leadingAnchor, constant: 8),
            warningSelectableLabel.trailingAnchor.constraint(equalTo: warningContainerView.trailingAnchor, constant: -8),
            warningSelectableLabel.bottomAnchor.constraint(equalTo: warningContainerView.bottomAnchor, constant: -8),
            
            fileButton.widthAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            fileButton.heightAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            
            cameraButton.widthAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            cameraButton.heightAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            
            premiumButton.widthAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            premiumButton.heightAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            
            settingsButton.widthAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            settingsButton.heightAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            
            footerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            footerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            toggleSelectionButton.heightAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            
            sortButton.widthAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            sortButton.heightAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            
            changeLayoutButton.widthAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            changeLayoutButton.heightAnchor.constraint(equalToConstant: UIConstants.Sizes.small),
            
            bottomGradientBlurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomGradientBlurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomGradientBlurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomGradientBlurView.topAnchor.constraint(equalTo: footerStackView.topAnchor, constant: -UIConstants.Padding.horizontal),
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
                return photoLayoutSection(layoutEnvironment)
            }
        }, configuration: configuration)
        
        return layout
    }
    
    private func createSpiralLayout() -> UICollectionViewLayout {
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
                return photoCustomLayoutSection(layoutEnvironment)
            }
        }, configuration: configuration)
        
        return layout
    }
    
    private func editorChoiceLayoutSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let isRegular = layoutEnvironment.traitCollection.horizontalSizeClass == .regular
        let contentSize = layoutEnvironment.container.contentSize
        let innerSpacing: CGFloat = 12.0
        let edgeInsets = NSDirectionalEdgeInsets(top: innerSpacing + UIConstants.Sizes.small, leading: 20, bottom: innerSpacing, trailing: 20)
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
    
    private func photoLayoutSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let isRegular = layoutEnvironment.traitCollection.horizontalSizeClass == .regular
        let innerSpacing: CGFloat = 2.0
        let itemCount = isRegular ? 6 : 4
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
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: innerSpacing, leading: 0, bottom: 140, trailing: 0)
        layoutSection.interGroupSpacing = innerSpacing

        return layoutSection
    }
    
    private func photoGridLayoutSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let innerSpacing: CGFloat = 2.0

        // Top Group
        
        let topItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )

        let topItem = NSCollectionLayoutItem(layoutSize: topItemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0 / 3.0)
        )

        let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [topItem, topItem])
        topGroup.interItemSpacing = .fixed(innerSpacing)
        
        // Bottom Group
        
        let leadingItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0 / 2.0)
        )
        
        let leadingItem = NSCollectionLayoutItem(layoutSize: leadingItemSize)
        
        let middleItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let middleItem = NSCollectionLayoutItem(layoutSize: middleItemSize)
        
        let leadingGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let leadingGroup = NSCollectionLayoutGroup.vertical(layoutSize: leadingGroupSize, subitems: [leadingItem, leadingItem])
        leadingGroup.interItemSpacing = .fixed(innerSpacing)
        
        let bottomGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(2.0 / 3.0)
        )
        
        let bottomGroup = NSCollectionLayoutGroup.horizontal(layoutSize: bottomGroupSize, subitems: [leadingGroup, middleItem, leadingGroup])
        bottomGroup.interItemSpacing = .fixed(innerSpacing)
        
        // Main Group
        
        let mainGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0)
        )
        
        let mainGroup = NSCollectionLayoutGroup.vertical(layoutSize: mainGroupSize, subitems: [topGroup, bottomGroup])
        mainGroup.interItemSpacing = .fixed(innerSpacing)
        
        let layoutSection = NSCollectionLayoutSection(group: mainGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: innerSpacing, leading: 0, bottom: innerSpacing, trailing: 0)
        layoutSection.interGroupSpacing = innerSpacing

        return layoutSection
    }
    
    private func photoCustomLayoutSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let innerSpacing: CGFloat = 2.0

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0)
        )
                    
        let group = NSCollectionLayoutGroup.custom(layoutSize: groupSize) { environment in
            let containerWidth = environment.container.effectiveContentSize.width
            let containerHeight = environment.container.effectiveContentSize.width
            let numberOfItemsUnitsByAbstraction: Int = 4
            let itemUnitSize = CGSize(
                width: (containerWidth - (CGFloat(numberOfItemsUnitsByAbstraction) - 1.0) * innerSpacing) / CGFloat(numberOfItemsUnitsByAbstraction),
                height: (containerHeight - (CGFloat(numberOfItemsUnitsByAbstraction) - 1.0) * innerSpacing) / CGFloat(numberOfItemsUnitsByAbstraction)
            )
            
            let firstItemFrame = CGRect(x: 0, y: 0, width: itemUnitSize.width * 2 + innerSpacing, height: itemUnitSize.height)
            let secondItemFrame = CGRect(x: CGRectGetMaxX(firstItemFrame) + innerSpacing, y: 0, width: itemUnitSize.width, height: itemUnitSize.height)
            let thirdItemFrame = CGRect(x: CGRectGetMaxX(secondItemFrame) + innerSpacing, y: 0, width: itemUnitSize.width, height: itemUnitSize.height * 2 + innerSpacing)
            let fourthItemFrame = CGRect(x: 0, y: CGRectGetMaxY(firstItemFrame) + innerSpacing, width: itemUnitSize.width, height: itemUnitSize.height)
            let fifthItemFrame = CGRect(x: CGRectGetMaxX(fourthItemFrame) + innerSpacing, y: CGRectGetMinY(fourthItemFrame), width: itemUnitSize.width * 2 + innerSpacing, height: itemUnitSize.height * 2 + innerSpacing)
            let sixthItemFrame = CGRect(x: 0, y: CGRectGetMaxY(fourthItemFrame) + innerSpacing, width: itemUnitSize.width, height: itemUnitSize.height * 2 + innerSpacing)
            let seventhItemFrame = CGRect(x: CGRectGetMinX(thirdItemFrame), y: CGRectGetMaxY(thirdItemFrame) + innerSpacing, width: itemUnitSize.width, height: itemUnitSize.height)
            let eighthItemFrame = CGRect(x: CGRectGetMaxX(sixthItemFrame) + innerSpacing, y: CGRectGetMaxY(fifthItemFrame) + innerSpacing, width: itemUnitSize.width, height: itemUnitSize.height)
            let ninthItemFrame = CGRect(x: CGRectGetMaxX(eighthItemFrame) + innerSpacing, y: CGRectGetMinY(eighthItemFrame), width: itemUnitSize.width * 2 + innerSpacing, height: itemUnitSize.height)
            
            return [
                NSCollectionLayoutGroupCustomItem(frame: firstItemFrame),
                NSCollectionLayoutGroupCustomItem(frame: secondItemFrame),
                NSCollectionLayoutGroupCustomItem(frame: thirdItemFrame),
                NSCollectionLayoutGroupCustomItem(frame: fourthItemFrame),
                NSCollectionLayoutGroupCustomItem(frame: fifthItemFrame),
                NSCollectionLayoutGroupCustomItem(frame: sixthItemFrame),
                NSCollectionLayoutGroupCustomItem(frame: seventhItemFrame),
                NSCollectionLayoutGroupCustomItem(frame: eighthItemFrame),
                NSCollectionLayoutGroupCustomItem(frame: ninthItemFrame)
            ]
        }

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = innerSpacing
        section.contentInsets = NSDirectionalEdgeInsets(top: innerSpacing, leading: 0, bottom: 140, trailing: 0)
        
        return section
    }
    
	private func configureCell(_ cell: EditorChoiceItemView, with editorChoice: RemoteConfigClient.EditorChoice) {
        DispatchQueue.main.async {
            print("🚦 CONFIGURE_EDITOR_CHOICE on Thread: \(DispatchQueue.currentLabel)")
            if let url = editorChoice.artworkURL {
                cell.backgroundImageView.kf.setImage(
                    with: url,
                    options: [
                        .loadDiskFileSynchronously,
                        .cacheOriginalImage,
                        .transition(.fade(0.25)),
                    ]
                )
            }
            
            if let url = editorChoice.miniIconURL {
                cell.iconImageView.kf.setImage(
                    with: url,
                    options: [
                        .loadDiskFileSynchronously,
                        .cacheOriginalImage,
                        .transition(.fade(0.25)),
                    ]
                )
            }
            
            cell.titleLabel.text = editorChoice.title
            cell.subtitleLabel.text = editorChoice.description
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
        store.send(.toggleOrderButtonTapped)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    @objc private func changeLayoutButtonTapped(_ sender: UIButton) {
        store.send(.toggleLayoutButtonTapped)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    @objc private func nextButtonTapped(_ sender: UIButton) {
        
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
                
                let numberOfSelectedPhotos = selectedIndexPaths.count
                placeholderBottomConstraint.constant = numberOfSelectedPhotos > 20 ? -(UIConstants.Spacing.inner + 70 + 20) : -UIConstants.Padding.horizontal
                
                UIView.animate(withDuration: 0.3) {
                    cell.selectButton.isSelected = true
                    cell.imageView.alpha = 0.75
                    
                    var countString = ""
                    if numberOfSelectedPhotos == 1 {
                        countString = "1 photo selected"
                    } else {
                        countString = "\(numberOfSelectedPhotos) photos selected"
                    }
                    self.countLabel.text = countString
                    self.nextButton.alpha = numberOfSelectedPhotos > 0 ? 1.0 : 0.0
                    self.nextButton.isEnabled = numberOfSelectedPhotos <= 20
                    self.warningContainerView.alpha = numberOfSelectedPhotos <= 20 ? 0.0 : 1.0
                    
                    self.view.layoutIfNeeded()
                }
            } else {
                switch item {
                case let .photo(asset):
                    store.send(.didSelectedItem(PhotoList.State.Item(asset: asset, indexPath: indexPath)))
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
            
            let numberOfSelectedPhotos = selectedIndexPaths.count
            placeholderBottomConstraint.constant = numberOfSelectedPhotos > 20 ? -(UIConstants.Spacing.inner + 70 + 20) : -UIConstants.Padding.horizontal
            
            UIView.animate(withDuration: 0.3) {
                cell.selectButton.isSelected = false
                cell.imageView.alpha = 1.0
                
                var countString = "No photos selected"
                if numberOfSelectedPhotos == 1 {
                    countString = "1 photo selected"
                } else {
                    countString = "\(numberOfSelectedPhotos) photos selected"
                }
                self.countLabel.text = countString
                self.nextButton.alpha = numberOfSelectedPhotos > 0 ? 1.0 : 0.0
                self.nextButton.isEnabled = numberOfSelectedPhotos <= 20
                self.warningContainerView.alpha = numberOfSelectedPhotos <= 20 ? 0.0 : 1.0
                
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension PhotoViewController: UICollectionViewDataSourcePrefetching {
        
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let photoIndexPaths = indexPaths.filter { $0.section == 1 }
        let assets = photoIndexPaths.compactMap { indexPath in
            if indexPath.item < store.photos.count {
                return store.photos[indexPath.item]
            } else {
                return nil
            }
        }
        imageManager.startCachingImages(for: assets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let photoIndexPaths = indexPaths.filter { $0.section == 1 }
        let assets = photoIndexPaths.compactMap { indexPath in
            if indexPath.item < store.photos.count {
                return store.photos[indexPath.item]
            } else {
                return nil
            }
        }
        imageManager.stopCachingImages(for: assets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
    }
}

// MARK: - UIScrollViewDelegate

extension PhotoViewController: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if store.isSelecting {
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.headerStackView.alpha = 0
            self.categoryView.alpha = 0
            self.toggleSelectionButton.alpha = 0
            self.sortButton.alpha = 0
            self.changeLayoutButton.alpha = 0
        })
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if store.isSelecting {
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.headerStackView.alpha = 1
            self.categoryView.alpha = 1
            self.toggleSelectionButton.alpha = 1
            self.sortButton.alpha = 1
            self.changeLayoutButton.alpha = 1
        })
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if store.isSelecting {
            return
        }
        
        if !decelerate {
            UIView.animate(withDuration: 0.3, animations: {
                self.headerStackView.alpha = 1
                self.categoryView.alpha = 1
                self.toggleSelectionButton.alpha = 1
                self.sortButton.alpha = 1
                self.changeLayoutButton.alpha = 1
            })
        }
    }
}

// MARK: - CategoryViewDelegate

extension PhotoViewController: CategoryViewDelegate {
        
    func categoryView(_ view: CategoryView, didSelect category: PhotosClient.Category) {
        print("🚦 CATEGORY_VIEW on Thread: \(DispatchQueue.currentLabel) - Category: \(category)")
        store.send(.didChangeCategory(category))
    }
}

// MARK: - NSDiffableDataSourceSnapshot

extension NSDiffableDataSourceSnapshot<PhotoViewController.Section, PhotoViewController.Item> {
    init(store: StoreOf<PhotoList>) {
        self.init()
        
        appendSections([.editorChoices])
        appendSections([.allPhotos])
        
        if !store.editorChoices.isEmpty && !store.isSelecting {
            appendItems(store.editorChoices.map { .editorChoice($0) }, toSection: .editorChoices)
        }
        
        if !store.photos.isEmpty {
            appendItems(store.photos.map { .photo($0) }, toSection: .allPhotos)
        }
    }
}

// MARK: - Execution Time Measurement

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
    print("⏰ \(label.uppercased()) executed on Thread: \(DispatchQueue.currentLabel) in \(elapsed) seconds")
}

extension DispatchQueue {
    public static var currentLabel: String {
        let name = __dispatch_queue_get_label(nil)
        if let label = String(cString: name, encoding: .utf8) {
            return label
        }
        return "Unknown"
    }
}
