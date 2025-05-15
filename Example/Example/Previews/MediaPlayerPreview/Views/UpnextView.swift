//
//  UpnextView.swift
//  Example
//
//  Created by Thanh Hai Khong on 7/5/25.
//

import UIKit
import SwiftUI
import Kingfisher
import UIKitPreviews

class UpnextView: UIView {
	
	typealias Section = Int
	typealias Item = PlayableWitness
	
	private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
	public var didReorder: (([Item]) -> Void)?
	
	// MARK: - View Lifecycle
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupViews()
		setupDataSource()
		initialSnapshot()
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup Views
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Up Next"
		label.font = UIFont.preferredFont(forTextStyle: .headline)
		label.textColor = .label
		return label
	}()
	
	private lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
		collectionView.register(TrackCell.self, forCellWithReuseIdentifier: TrackCell.identifier)
		return collectionView
	}()
}

// MARK: - Private Methods

extension UpnextView {
	
	private func createLayout() -> UICollectionViewLayout {
		return UICollectionViewCompositionalLayout { section, layoutEnvironment in
			var configuration = UICollectionLayoutListConfiguration(appearance: UICollectionLayoutListConfiguration.Appearance.plain)
			configuration.showsSeparators = false
			return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
		}
	}
	
	private func setupViews() {
		backgroundColor = .white
		
		addSubview(collectionView)
		
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	private func setupDataSource() {
		let cellRegistration = UICollectionView.CellRegistration<TrackCell, Item> { cell, indexPath, item in
			cell.configureCell(item, isMovable: true)
			let reorderAccessory = UICellAccessory.reorder(displayed: .always)
			cell.accessories = [reorderAccessory]
		}
		
		dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
			let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
			return cell
		}
		
		dataSource.reorderingHandlers.canReorderItem = { _ in
			return true
		}
		
		dataSource.reorderingHandlers.didReorder = { [weak self] transaction in
			guard let `self` else { return }
			let newSnapshot = transaction.finalSnapshot
			self.didReorder?(newSnapshot.itemIdentifiers)
		}
	}
	
	private func initialSnapshot() {
		var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
		snapshot.appendSections([0])
		snapshot.appendItems([], toSection: 0)
		
		DispatchQueue.main.async {
			self.dataSource.apply(snapshot, animatingDifferences: false)
		}
	}
}

// MARK: - Public Methods

extension UpnextView {
	public func configureView(_ items: [PlayableWitness]) {
		var snapshot = dataSource.snapshot()
		snapshot.deleteAllItems()
		snapshot.appendSections([0])
		snapshot.appendItems(items, toSection: 0)
		
		DispatchQueue.main.async {
			self.dataSource.apply(snapshot, animatingDifferences: true)
		}
	}
}
