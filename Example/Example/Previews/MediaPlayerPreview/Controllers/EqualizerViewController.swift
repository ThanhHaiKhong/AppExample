//
//  EqualizerViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 24/4/25.
//

import ComposableArchitecture
import MediaPlayerClient
import UIKitPreviews
import UIExtensions
import TimerClient
import SwiftUI
import UIKit
import Hero

class EqualizerViewController: UIViewController {
	
	enum Item: Hashable {
		case preset(MediaPlayerClient.EqualizerPreset)
		case band(MediaPlayerClient.EqualizerBand)
		case accessory(AccessoryCell.Position)
	}
	
	private let store: StoreOf<EqualizerStore>
	
	public init(store: StoreOf<EqualizerStore>) {
		self.store = store
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    typealias Section = Int
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var selectedIndexPath: IndexPath? {
        didSet {
            guard let selectedIndexPath = selectedIndexPath,
                  let item = dataSource.itemIdentifier(for: selectedIndexPath),
				  case let .preset(preset) = item
			else {
                return
            }
            
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
            let bands: [MediaPlayerClient.EqualizerBand] = preset.bands
            
            for i in 0..<bands.count {
				let indexPath = IndexPath(item: i + 1, section: 0)
				if let cell = collectionView.cellForItem(at: indexPath) as? BandCell {
					let gain = bands[i].gain
					cell.configureCell(gain)
					if store.isEnabled {
						store.send(.setEqualizer(gain, i))
					}
				}
            }
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupGesture()
        setupDataSource()
        initialSnapshot()
		
		observe { [weak self] in
			guard let `self` = self else { return }
			UIView.animate(withDuration: 0.3) {
				self.collectionView.isUserInteractionEnabled = self.store.isEnabled
				self.containerView.alpha = self.store.isEnabled ? 1.0 : 0.5
				self.toggleSwitch.isOn = self.store.isEnabled
			}
		}
		
		store.send(.onDidLoad)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupLayoutConstraints()
    }
    
    // MARK: - Views
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
	
	public lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Equalizer"
		label.textColor = .blueBerry
		label.font = UIFont.preferredFont(forTextStyle: .largeTitle, weight: .heavy)
		return label
	}()
    
	private lazy var toggleSwitch: UISwitch = {
		let toggleSwitch = UISwitch()
		toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
		toggleSwitch.onTintColor = .redPink
		toggleSwitch.tintColor = .blueBerry
		toggleSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
		toggleSwitch.addTarget(self, action: #selector(toggleEqualizer), for: .valueChanged)
		return toggleSwitch
	}()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    public lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
		collectionView.register(AccessoryCell.self, forCellWithReuseIdentifier: AccessoryCell.identifier)
		collectionView.register(BandCell.self, forCellWithReuseIdentifier: BandCell.identifier)
        collectionView.register(EqualizerCell.self, forCellWithReuseIdentifier: EqualizerCell.identifier)
        return collectionView
    }()
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
}

// MARK: - Initialization

extension EqualizerViewController {
    
    private func createLayout() -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = .zero
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
			let isBandSection = sectionIndex == 0
			let contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: isBandSection ? 0.0 : 20.0, bottom: 20.0, trailing: isBandSection ? 0.0 : 20.0)
			
			let itemWidth: NSCollectionLayoutDimension = .fractionalWidth(isBandSection ? 1.0 : 1.0)
			let itemHeight: NSCollectionLayoutDimension = .fractionalHeight(isBandSection ? 1.0 : 0.5)
			
			let itemSize = NSCollectionLayoutSize(widthDimension: itemWidth, heightDimension: itemHeight)
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			
			let groupWidth: NSCollectionLayoutDimension = isBandSection ? .fractionalWidth(1.0 / 12.0) : .absolute(160.0)
			let groupHeight: NSCollectionLayoutDimension = isBandSection ? .absolute(300) : .absolute(100.0)
			let interGroupSpacing: CGFloat = isBandSection ? 0.0 : 12.0
			
			let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: groupHeight)
			let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
			group.interItemSpacing = .fixed(12.0)
			
			let section = NSCollectionLayoutSection(group: group)
			section.orthogonalScrollingBehavior = .continuous
			section.interGroupSpacing = interGroupSpacing
			section.contentInsets = contentInsets
			return section
        }, configuration: configuration)
        
        return layout
    }
    
	private func setupViews() {
		view.backgroundColor = .systemBackground
		headerStackView.backgroundColor = .systemBackground
		containerView.backgroundColor = .systemBackground
		collectionView.backgroundColor = .systemBackground
		
		headerStackView.addArrangedSubview(titleLabel)
		headerStackView.addArrangedSubview(toggleSwitch)
		
		containerView.addSubview(headerStackView)
		containerView.addSubview(collectionView)
		
		view.addSubview(blurEffectView)
		view.addSubview(containerView)
		
		collectionView.hero.modifiers = [.fade, .spring(stiffness: 200, damping: 200)]
		headerStackView.hero.modifiers = [.fade, .useOptimizedSnapshot]
	}
    
	private func setupLayoutConstraints() {
		NSLayoutConstraint.activate([
			self.blurEffectView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
			self.blurEffectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.blurEffectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.blurEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			
			self.containerView.centerYAnchor.constraint(equalTo: self.blurEffectView.centerYAnchor),
			self.containerView.leadingAnchor.constraint(equalTo: self.blurEffectView.leadingAnchor),
			self.containerView.trailingAnchor.constraint(equalTo: self.blurEffectView.trailingAnchor),
			self.containerView.heightAnchor.constraint(equalToConstant: 522),
			
			self.headerStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 12),
			self.headerStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
			self.headerStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
			self.headerStackView.heightAnchor.constraint(equalToConstant: 50),
			
			self.collectionView.topAnchor.constraint(equalTo: self.headerStackView.bottomAnchor, constant: 20),
			self.collectionView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
			self.collectionView.heightAnchor.constraint(equalToConstant: 440),
		])
	}
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		blurEffectView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        blurEffectView.addGestureRecognizer(panGesture)
    }
    
    private func setupDataSource() {
		let accessoryRegistration = UICollectionView.CellRegistration<AccessoryCell, Item> { cell, indexPath, item in
			guard case let .accessory(position) = item else {
				return
			}
			cell.configure(position: position)
		}
		
        let bandRegistration = UICollectionView.CellRegistration<BandCell, Item> { cell, indexPath, item in
			guard case let .band(band) = item else {
				return
			}
			cell.titleLabel.text = band.displayFrequency
			cell.slider.tag = indexPath.item - 1
			cell.slider.value = band.gain
			cell.delegate = self
        }
		
		let presetRegistration = UICollectionView.CellRegistration<EqualizerCell, Item> { cell, indexPath, item in
			guard case let .preset(preset) = item else {
				return
			}
			cell.titleLabel.text = preset.name
			cell.contentView.backgroundColor = self.selectedIndexPath == indexPath ? .redPink : .systemGray2
		}
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
			if indexPath.section == 0 {
				if case .accessory = item {
					let cell = collectionView.dequeueConfiguredReusableCell(using: accessoryRegistration, for: indexPath, item: item)
					return cell
				} else {
					let cell = collectionView.dequeueConfiguredReusableCell(using: bandRegistration, for: indexPath, item: item)
					return cell
				}
			} else {
				let cell = collectionView.dequeueConfiguredReusableCell(using: presetRegistration, for: indexPath, item: item)
				return cell
			}
        }
    }
    
    private func initialSnapshot() {
		var bands: [Item] = MediaPlayerClient.EqualizerBand.default.map { Item.band($0) }
		bands.insert(.accessory(.left), at: 0)
		bands.append(.accessory(.right))
		
		let presets: [Item] = MediaPlayerClient.EqualizerPreset.allPresets.map { Item.preset($0) }
		
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([0, 1])
		snapshot.appendItems(bands, toSection: 0)
        snapshot.appendItems(presets, toSection: 1)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Actions

extension EqualizerViewController {
    
    @objc private func toggleEqualizer(_ sender: UISwitch) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		store.send(.setEnabled(sender.isOn))
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        dismiss(animated: true)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .began:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            dismiss(animated: true)
            
        case .changed:
            Hero.shared.update(translation.y / view.bounds.height)
            
        default:
            let velocity = gesture.velocity(in: view)
            
            if ((translation.y + velocity.y) / view.bounds.height) > 0.5 {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension EqualizerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EqualizerCell else {
            return
        }
        
        for visibleIndexPath in collectionView.indexPathsForVisibleItems {
            if let visibleCell = collectionView.cellForItem(at: visibleIndexPath) as? EqualizerCell {
                visibleCell.contentView.backgroundColor = .systemGray2
            }
        }
        
        cell.contentView.backgroundColor = .redPink
        
        selectedIndexPath = indexPath
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
    }
}

// MARK: - BandCellDelegate

extension EqualizerViewController: BandCellDelegate {
	
	func didChangeValue(value: Float, index: Int) {
		if store.isEnabled {
			store.send(.setEqualizer(value, index))
		}
	}
}

struct EqualizerViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
			EqualizerViewController(store: Store(initialState: EqualizerStore.State()) {
				EqualizerStore()
			})
        }
    }
}
