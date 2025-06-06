//
//  RelatedView.swift
//  Example
//
//  Created by Thanh Hai Khong on 8/5/25.
//

import UIKit
import SwiftUI
import UIKitPreviews

class RelatedView: UIView {
	
	typealias Section = Int
	typealias Item = PlayableWitness
	
	private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupViews()
		setupDataSource()
		initialSnapshot()
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
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

extension RelatedView {
	
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
			cell.configureCell(item, isMovable: false)
		}
		
		dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
			let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
			return cell
		}
	}
	
	private func initialSnapshot() {
		var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
		snapshot.appendSections([0])
		snapshot.appendItems([], toSection: 0)
		
		dataSource.apply(snapshot, animatingDifferences: false)
	}
}
