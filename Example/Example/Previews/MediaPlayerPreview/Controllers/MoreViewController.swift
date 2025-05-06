//
//  MoreViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 26/4/25.
//

import UIKitPreviews
import UIExtensions
import SwiftUI
import UIKit
import Hero

public class MoreViewController: UIViewController {
    
    public struct MoreAction: Hashable, Equatable, Identifiable {
        public let id = UUID().uuidString
        public let name: String
        public let imageNamed: String
        public let tintColor: UIColor
        
        public init(name: String, imageNamed: String, tintColor: UIColor) {
            self.name = name
            self.imageNamed = imageNamed
            self.tintColor = tintColor
        }
        
        public static let addToPlaylist = MoreAction(name: "Add to Playlist", imageNamed: "cricket.ball.circle.fill", tintColor: .systemGreen)
        public static let addToLibrary = MoreAction(name: "Add to Library", imageNamed: "american.football.circle.fill", tintColor: .systemBlue)
        public static let share = MoreAction(name: "Share", imageNamed: "sun.max.circle.fill", tintColor: .systemPurple)
        public static let removeFromLibrary = MoreAction(name: "Remove from Library", imageNamed: "location.north.circle.fill", tintColor: .systemRed)
    }
    
    typealias Section = Int
    typealias Item = MoreAction
    
    private var dataSource: UITableViewDiffableDataSource<Section, Item>!
    private var actions: [MoreAction] = [.addToPlaylist, .addToLibrary, .share, .removeFromLibrary]
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

extension MoreViewController {
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        headerView.backgroundColor = .systemBackground
        footerView.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.height - CGFloat(actions.count) * cellHeight) / 2)
        headerView.titleLabel.text = "More"
        tableView.tableHeaderView = headerView
        
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.height - CGFloat(actions.count) * cellHeight) / 2)
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
        dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var content = UIListContentConfiguration.cell()
            content.text = item.name
            content.textProperties.color = .blueBerry
            content.textProperties.font = UIFont.preferredFont(forTextStyle: .headline, weight: .semibold)
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
            content.image = UIImage(systemName: item.imageNamed, withConfiguration: imageConfig)
            content.imageProperties.tintColor = item.tintColor
            cell.contentConfiguration = content
            return cell
        }
    }
    
    private func initializeSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems(actions, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Actions

extension MoreViewController {
    
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

extension MoreViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

struct MoreViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            MoreViewController()
        }
    }
}
