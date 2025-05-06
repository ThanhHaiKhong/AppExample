//
//  PlaybackSpeedViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 26/4/25.
//

import UIKitPreviews
import UIExtensions
import SwiftUI
import UIKit
import Hero

public class PlaybackSpeedViewController: UIViewController {
    
    typealias Section = Int
    typealias Item = PlayerStore.State.SpeedMode
    
    private var dataSource: UITableViewDiffableDataSource<Section, Item>!
    private let cellHeight: CGFloat = 60
    private var numberOfItems: Int = PlayerStore.State.SpeedMode.allCases.count
    var currentSpeed: PlayerStore.State.SpeedMode = .normal
    
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

extension PlaybackSpeedViewController {
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        headerView.backgroundColor = .systemBackground
        footerView.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.height - CGFloat(numberOfItems) * cellHeight) / 2)
        headerView.titleLabel.text = "Speed"
        tableView.tableHeaderView = headerView
        
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.height - CGFloat(numberOfItems) * cellHeight) / 2)
        tableView.tableFooterView = footerView
        
        view.addSubview(tableView)
        
        configureHero()
    }
    
    private func configureHero() {
        tableView.hero.modifiers = [.fade, .useGlobalCoordinateSpace, .useOptimizedSnapshot, .spring(stiffness: 200, damping: 200)]
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
            guard let `self` else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var content = UIListContentConfiguration.cell()
            content.text = item.description
            content.textProperties.color = .blueBerry
            content.textProperties.font = UIFont.preferredFont(forTextStyle: .headline, weight: .semibold)
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
            content.image = UIImage(systemName: item.imageNamed, withConfiguration: imageConfig)
            content.imageProperties.tintColor = item.tintColor
            cell.accessoryType = self.currentSpeed == item ? .checkmark : .none
            cell.contentConfiguration = content
            return cell
        }
    }
    
    private func initializeSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems(PlayerStore.State.SpeedMode.allCases, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Actions

extension PlaybackSpeedViewController {
    
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

extension PlaybackSpeedViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = dataSource.itemIdentifier(for: indexPath) {
            currentSpeed = item
        }
        dismiss(animated: true)
    }
}

struct PlaybackSpeedViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            MainViewController()
        }
    }
}

class AnimationDemoViewController: UIViewController {
    
    private let animatedView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let animateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Animate!", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var animationStep = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        animateButton.addTarget(self, action: #selector(animateAction), for: .touchUpInside)
    }
    
    private func setupLayout() {
        view.addSubview(animatedView)
        view.addSubview(animateButton)
        
        NSLayoutConstraint.activate([
            animatedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animatedView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animatedView.widthAnchor.constraint(equalToConstant: 100),
            animatedView.heightAnchor.constraint(equalToConstant: 100),
            
            animateButton.topAnchor.constraint(equalTo: animatedView.bottomAnchor, constant: 40),
            animateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func animateAction() {
        switch animationStep {
        case 0:
            performBasicAnimation()
        case 1:
            performKeyframeAnimation()
        case 2:
            performPropertyAnimator()
        default:
            break
        }
        animationStep = (animationStep + 1) % 3
    }
    
    private func performBasicAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.animatedView.transform = self.animatedView.transform.scaledBy(x: 1.5, y: 1.5)
            self.animatedView.backgroundColor = .systemRed
        }
    }
    
    private func performKeyframeAnimation() {
        UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: []) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.33) {
                self.animatedView.transform = CGAffineTransform(translationX: -30, y: 0)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.33, relativeDuration: 0.33) {
                self.animatedView.transform = CGAffineTransform(translationX: 30, y: 0)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.66, relativeDuration: 0.34) {
                self.animatedView.transform = .identity
            }
        }
    }
    
    private func performPropertyAnimator() {
        let animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut) {
            self.animatedView.transform = self.animatedView.transform.rotated(by: .pi)
        }
        animator.startAnimation()
    }
}

class ContextMenuDemoViewController: UIViewController {
    
    private let sampleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupContextMenu()
    }
    
    private func setupLayout() {
        view.addSubview(sampleView)
        NSLayoutConstraint.activate([
            sampleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sampleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            sampleView.widthAnchor.constraint(equalToConstant: 150),
            sampleView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setupContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        sampleView.addInteraction(interaction)
    }
}

extension ContextMenuDemoViewController: UIContextMenuInteractionDelegate {
    
    // Khi user giữ lâu -> hệ thống hỏi delegate: "Bạn muốn menu gì?"
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            // Đây là menu thực tế
            let action1 = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                print("Edit tapped")
            }
            let action2 = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                print("Delete tapped")
            }
            
            return UIMenu(title: "Actions", children: [action1, action2])
        }
    }
}

class MainViewController: UIViewController {
    
    private var buttonWidthConstraint: NSLayoutConstraint!
    private var buttonHeightConstraint: NSLayoutConstraint!
    private var buttonCenterXConstraint: NSLayoutConstraint!
    private var buttonBottomConstraint: NSLayoutConstraint!
    
    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_dot")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(imageView)
        view.addSubview(plusButton)
        
        buttonWidthConstraint = plusButton.widthAnchor.constraint(equalToConstant: 60)
        buttonHeightConstraint = plusButton.heightAnchor.constraint(equalToConstant: 60)
        buttonCenterXConstraint = plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        buttonBottomConstraint = plusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -0.0)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            buttonWidthConstraint,
            buttonHeightConstraint,
            buttonCenterXConstraint,
            buttonBottomConstraint
        ])
        
        plusButton.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
    }
    
    @objc private func plusButtonTapped() {
        animateButtonExpansion()
    }
    
    private func animateButtonExpansion() {
        view.layoutIfNeeded()
        
        // Fade out icon
        UIView.animate(withDuration: 0.2) {
            self.plusButton.imageView?.alpha = 0
        }
        
        // Expand button to cover the entire screen
        buttonWidthConstraint.constant = view.bounds.width
        buttonHeightConstraint.constant = view.bounds.height
        buttonCenterXConstraint.constant = 0
        buttonBottomConstraint.isActive = false
        
        plusButton.layer.cornerRadius = 0
        plusButton.layer.masksToBounds = false
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.openMenu()
        })
    }
    
    @objc private func openMenu() {
        let menuVC = MenuViewController()
        menuVC.modalPresentationStyle = .custom
        menuVC.transitioningDelegate = self
        present(menuVC, animated: true)
    }
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return DimmedBackgroundPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class DimmedBackgroundPresentationController: UIPresentationController {
    
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        view.alpha = 0
        return view
    }()
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .prominent)
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0
        return view
    }()
    
    override func presentationTransitionWillBegin() {
        guard let containerView else { return }
        blurEffectView.frame = containerView.bounds
        containerView.insertSubview(blurEffectView, at: 0)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.blurEffectView.alpha = 1
        })
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.blurEffectView.alpha = 0
        })
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }
        let height: CGFloat = 500
        return CGRect(x: 0, y: containerView.bounds.height - height, width: containerView.bounds.width, height: height)
    }
}

class MenuViewController: UIViewController {
    
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStackView()
        setupButtons()
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30)
        ])
    }
    
    private func setupButtons() {
        let titles = ["Photo", "Camera", "Files", "Location", "Settings"]
        for title in titles {
            let button = UIButton(type: .system)
//            let config = UIButton.Configuration.plain()
//            config.imagePadding = 20
//            button.configuration = config
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            button.alpha = 0
            button.transform = CGAffineTransform(translationX: 0, y: 20)
            button.addTarget(self, action: #selector(handleButtonTap(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            buttons.append(button)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateButtons()
    }
    
    private func animateButtons() {
        for (index, button) in buttons.enumerated() {
            UIView.animate(withDuration: 0.4,
                           delay: Double(index) * 0.05,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 0.5,
                           options: [],
                           animations: {
                button.alpha = 1
                button.transform = .identity
            }, completion: nil)
        }
    }
    
    @objc private func handleButtonTap(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        print("\(title) button tapped")
        dismiss(animated: true)
    }
}
