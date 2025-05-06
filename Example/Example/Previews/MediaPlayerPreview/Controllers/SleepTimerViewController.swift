//
//  SleepTimerViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 26/4/25.
//

import ComposableArchitecture
import UIKitPreviews
import UIExtensions
import SwiftUI
import UIKit
import Hero

public class SleepTimerViewController: UIViewController {
	
	@Perception.Bindable private var store: StoreOf<SleepTimer>
	
	public init(store: StoreOf<SleepTimer>) {
		self.store = store
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    typealias Section = Int
    typealias Item = PlayerStore.State.SleepMode
    
    private var dataSource: UITableViewDiffableDataSource<Section, Item>!
    private let numberOfItems: Int = PlayerStore.State.SleepMode.allCases.count
    private let cellHeight: CGFloat = 60
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupGestures()
        setupDataSource()
        initializeSnapshot()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupLayoutConstraints()
    }
    
    // MARK: - Properties
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var headerView: TableHeaderView = {
        let view = TableHeaderView()
        return view
    }()
    
    private var footerView: UIView = {
        let view = UIView()
        return view
    }()
}

// MARK: - SetupViews

extension SleepTimerViewController {
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        headerView.backgroundColor = .systemBackground
        footerView.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.height - CGFloat(numberOfItems) * cellHeight) / 2)
        tableView.tableHeaderView = headerView
        
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.height - CGFloat(numberOfItems) * cellHeight) / 2)
        tableView.tableFooterView = footerView
        
        view.addSubview(tableView)
        
        configureHero()
    }
    
    private func configureHero() {
        tableView.hero.modifiers = [.fade, .spring(stiffness: 200, damping: 200)]
    }
    
    private func setupGestures() {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        headerView.addGestureRecognizer(tap1)
        footerView.addGestureRecognizer(tap2)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { [weak self] tableView, indexPath, item in
            guard let `self` = self else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var content = UIListContentConfiguration.cell()
            content.text = item.description
            content.textProperties.color = .blueBerry
            content.textProperties.font = UIFont.preferredFont(forTextStyle: .headline, weight: .semibold)
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
            content.image = UIImage(systemName: "timer.circle.fill", withConfiguration: imageConfig)
            content.imageProperties.tintColor = item.tintColor
			cell.accessoryType = self.store.sleepMode == item ? .checkmark : .none
            cell.contentConfiguration = content
            return cell
        }
    }
    
    private func initializeSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems(PlayerStore.State.SleepMode.allCases, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Actions

extension SleepTimerViewController {
    
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

// MARK: - UITableViewDelegate

extension SleepTimerViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
		guard let item = dataSource.itemIdentifier(for: indexPath) else {
			return
		}
		
		dismiss(animated: true) {
			self.store.send(.setSleepMode(item))
		}
    }
}

public class TableHeaderView: UIView {
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .systemBackground
		
		addSubview(titleLabel)
		
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
		])
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Sleep Timer"
		label.textColor = .blueBerry
		label.font = UIFont.preferredFont(forTextStyle: .largeTitle, weight: .heavy)
		return label
	}()
}

struct SleepTimerViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
			SleepTimerViewController(store: Store(initialState: SleepTimer.State()) {
				SleepTimer()
			})
        }
    }
}
