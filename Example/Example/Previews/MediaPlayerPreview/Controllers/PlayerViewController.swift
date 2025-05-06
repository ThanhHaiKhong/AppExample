//
//  PlayerViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 23/4/25.
//

import ComposableArchitecture
import MediaPlayerClient
import DataExtensions
import UIKitPreviews
import UIExtensions
import Kingfisher
import SwiftUI
import UIKit
import Hero

class PlayerViewController: UIViewController {
	
	private let store: StoreOf<PlayerStore>
	
	public init(store: StoreOf<PlayerStore>) {
		self.store = store
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupViews()
		store.send(.initializeMediaPlayer(containerView))
		
		observe { [weak self] in
			guard let `self` = self else {
				return
			}
			
			self.currentTimeLabel.text = "\(store.currentTime.timeString)"
			
			if self.timeSlider.maximumValue != Float(store.duration) {
				self.timeSlider.maximumValue = Float(store.duration)
				self.durationLabel.text = "\(store.duration.timeString)"
			}
			
			if !store.isDragging {
				self.timeSlider.setValue(Float(store.currentTime), animated: true)
			}
			
			self.timeSlider.isEnabled = store.duration != .zero
		}
		
		observe { [weak self] in
			guard let `self` = self else {
				return
			}
			
			self.playPauseButton.isSelected = self.store.isPlaying
			self.titleLabel.text = self.store.currentItem?.title
			self.artistLabel.text = self.store.currentItem?.artist
			
			if let thumbnailURL = store.currentItem?.thumbnailURL {
				self.imageView.kf.setImage(with: thumbnailURL)
			}
			
			if store.isLoading {
				self.loadingIndicator.startAnimating()
				self.playPauseButton.alpha = 0
			} else {
				self.loadingIndicator.stopAnimating()
				self.playPauseButton.alpha = 1
			}
		}
		
		observe { [weak self] in
			guard let `self` = self else {
				return
			}
			
			UIView.transition(with: self.shuffleButton, duration: 0.3, options: [.transitionFlipFromTop]) {
				self.shuffleButton.tintColor = self.store.shuffleMode == .on ? .redPink : .blueBerry
			}
		}
		
		observe { [weak self] in
			guard let `self` = self else {
				return
			}
			
			UIView.transition(with: self.repeatButton, duration: 0.3, options: [.transitionFlipFromTop]) {
				self.repeatButton.setImage(UIImage(systemName: self.store.repeatMode == .one ? "repeat.1" : "repeat", withConfiguration: UIImage.SymbolConfiguration.smallSymbol), for: .normal)
				self.repeatButton.tintColor = self.store.repeatMode == .off ? .blueBerry : .redPink
			}
		}
		
		observe { [weak self] in
			guard let `self` = self else {
				return
			}
			
			UIView.animate(withDuration: 0.5) {
				self.imageView.isHidden = self.store.playMode == .video
				self.equalizerButton.tintColor = self.store.equalizerStore.isEnabled ? .redPink : .blueBerry
			}
		}
		
		observe { [weak self] in
			guard let `self` = self else {
				return
			}
			
			var configuration = UIButton.Configuration.plain()
			
			if self.store.sleepTimer.isTimerRunning {
				let remainingString = self.store.sleepTimer.remainingTime?.timeString ?? ""
				configuration.title = remainingString
				configuration.attributedTitle = AttributedString(remainingString, attributes: AttributeContainer([.font: UIFont.preferredFont(forTextStyle: .headline, weight: .semibold)]))
				configuration.baseForegroundColor = .redPink
				configuration.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
			} else {
				let config: UIImage.Configuration = UIImage.SymbolConfiguration.smallSymbol
				let image = UIImage(systemName: "timer", withConfiguration: config)
				configuration.baseForegroundColor = .blueBerry
				configuration.image = image
			}
			
			UIView.transition(with: self.timerButton, duration: 0.3, options: [.transitionFlipFromTop]) {
				self.timerButton.configuration = configuration
			}
		}
		
		observe { [weak self] in
			guard let `self` = self else {
				return
			}
			
			var configuration = UIButton.Configuration.plain()
			configuration.title = self.store.speedMode.title
			configuration.attributedTitle = AttributedString(self.store.speedMode.title, attributes: AttributeContainer([.font: UIFont.preferredFont(forTextStyle: .headline, weight: .semibold)]))
			configuration.baseForegroundColor = self.store.speedMode == .normal ? .blueBerry : .redPink
			configuration.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
			
			UIView.transition(with: self.rateButton, duration: 0.3, options: [.transitionFlipFromTop]) {
				self.rateButton.configuration = configuration
			}
		}
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupLayoutContraints()
    }
    
    // MARK: - Properties
	
	private lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 10
		return imageView
	}()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.smallSymbol
        let image = UIImage(systemName: "chevron.down", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .blueBerry
        button.addTarget(self, action: #selector(dismissButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.smallSymbol
        let image = UIImage(systemName: "ellipsis", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .blueBerry
        button.addTarget(self, action: #selector(moreButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var switchModeControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Audio", "Video"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .subheadline, weight: .semibold),
            .foregroundColor: UIColor.blueBerry
        ]
        control.setTitleTextAttributes(normalAttributes, for: .normal)
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .subheadline, weight: .bold),
            .foregroundColor: UIColor.redPink
        ]
        control.setTitleTextAttributes(selectedAttributes, for: .selected)
		control.addTarget(self, action: #selector(switchModeValueChanged(_:)), for: .valueChanged)
        return control
    }()
    
    private lazy var containerView: UIView  = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var titleLabel: UILabel  = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You belong with me"
        label.font = UIFont.preferredFont(forTextStyle: .title2, weight: .medium, design: .rounded)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var artistLabel: UILabel  = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Taylor Swift"
        label.font = UIFont.preferredFont(forTextStyle: .headline, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var currentTimeLabel: UILabel  = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "02:20"
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var durationLabel: UILabel  = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "04:41"
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.largeSymbol
        let image = UIImage(systemName: "play.fill", withConfiguration: configuration)
        let selectedImage = UIImage(systemName: "pause.fill", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.tintColor = .redPink
        button.addTarget(self, action: #selector(togglePlayPause(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var prevButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.mediumSymbol
        let image = UIImage(systemName: "backward.end.fill", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .redPink
        button.addTarget(self, action: #selector(prevButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.mediumSymbol
        let image = UIImage(systemName: "forward.end.fill", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .redPink
        button.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var shuffleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.smallSymbol
        let image = UIImage(systemName: "shuffle", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .blueBerry
        button.addTarget(self, action: #selector(shuffleButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var repeatButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.smallSymbol
        let image = UIImage(systemName: "repeat", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .blueBerry
        button.addTarget(self, action: #selector(repeatButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var rateButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
		button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private lazy var timerButton: UIButton = {
        let button = UIButton(type: .system)
        let config: UIImage.Configuration = UIImage.SymbolConfiguration.smallSymbol
        let image = UIImage(systemName: "timer", withConfiguration: config)
        button.tintColor = .blueBerry
		var configuration = UIButton.Configuration.plain()
		configuration.image = image
		configuration.baseForegroundColor = .blueBerry
		button.configuration = configuration
        button.addTarget(self, action: #selector(timerButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var equalizerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.smallSymbol
        let image = UIImage(systemName: "slider.vertical.3", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .blueBerry
        button.addTarget(self, action: #selector(equalizerButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var upnextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        var configuration = UIButton.Configuration.plain()
        configuration.title = "UP NEXT"
        configuration.baseForegroundColor = .blueBerry
        configuration.attributedTitle = AttributedString("UP NEXT", attributes: AttributeContainer([.font: UIFont.preferredFont(forTextStyle: .headline, weight: .bold)]))
        button.configuration = configuration
        button.addTarget(self, action: #selector(upnextButtonTapped(_:)), for: .touchUpInside)
        button.backgroundColor = .white
        return button
    }()
    
    private lazy var lyricButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let title = "LYRICS"
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.baseForegroundColor = .blueBerry
        configuration.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: UIFont.preferredFont(forTextStyle: .headline, weight: .bold)]))
        button.configuration = configuration
        button.addTarget(self, action: #selector(lyricsButtonTapped(_:)), for: .touchUpInside)
        button.backgroundColor = .white
        return button
    }()
    
    private lazy var relatedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let title = "RELATED"
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.baseForegroundColor = .blueBerry
        configuration.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: UIFont.preferredFont(forTextStyle: .headline, weight: .bold)]))
        button.configuration = configuration
        button.addTarget(self, action: #selector(relatedButtonTapped(_:)), for: .touchUpInside)
        button.backgroundColor = .white
        return button
    }()
    
    private lazy var timeSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
        slider.tintColor = .redPink
        slider.minimumTrackTintColor = .redPink
        slider.maximumTrackTintColor = .blueBerry
        slider.setThumbImage(UIImage(named: "icon_dot"), for: .normal)
		slider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
		slider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        return slider
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var playbackStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var sliderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var controlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
		stackView.spacing = .zero
        return stackView
    }()
    
    private lazy var lyricStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.tintColor = .white
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = .systemGray5
        indicator.layer.cornerRadius = 30
        indicator.layer.masksToBounds = true
        return indicator
    }()
}

// MARK: - Setup Views

extension PlayerViewController {
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        headerStackView.addArrangedSubview(dismissButton)
        headerStackView.addArrangedSubview(switchModeControl)
        headerStackView.addArrangedSubview(moreButton)
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(artistLabel)
        
        titleLabel.setContentHuggingPriority(.required, for: .vertical) // Hug content tightly
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical) // Resist shrinking
        titleLabel.numberOfLines = 1 // Allow multiline, but rely on intrinsic size
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        artistLabel.setContentHuggingPriority(.required, for: .vertical)
        artistLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        artistLabel.numberOfLines = 1
        artistLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        playbackStackView.addArrangedSubview(prevButton)
        playbackStackView.addArrangedSubview(playPauseButton)
        playbackStackView.addArrangedSubview(nextButton)
        playbackStackView.setContentHuggingPriority(.defaultLow, for: .vertical) // Encourage playbackStackView to stretch vertically
        
        let playbackButtonHeight: CGFloat = 60.0
        prevButton.setContentHuggingPriority(.required, for: .vertical)
        prevButton.setContentCompressionResistancePriority(.required, for: .vertical)
        prevButton.heightAnchor.constraint(equalToConstant: playbackButtonHeight).isActive = true // Explicit height
        
        playPauseButton.setContentHuggingPriority(.required, for: .vertical)
        playPauseButton.setContentCompressionResistancePriority(.required, for: .vertical)
        playPauseButton.heightAnchor.constraint(equalToConstant: playbackButtonHeight).isActive = true
        
        nextButton.setContentHuggingPriority(.required, for: .vertical)
        nextButton.setContentCompressionResistancePriority(.required, for: .vertical)
        nextButton.heightAnchor.constraint(equalToConstant: playbackButtonHeight).isActive = true
        
        sliderStackView.addArrangedSubview(currentTimeLabel)
        sliderStackView.addArrangedSubview(timeSlider)
        sliderStackView.addArrangedSubview(durationLabel)
        
        controlsStackView.addArrangedSubview(shuffleButton)
        controlsStackView.addArrangedSubview(repeatButton)
        controlsStackView.addArrangedSubview(rateButton)
        controlsStackView.addArrangedSubview(timerButton)
        controlsStackView.addArrangedSubview(equalizerButton)
        
        lyricStackView.addArrangedSubview(upnextButton)
        lyricStackView.addArrangedSubview(lyricButton)
        lyricStackView.addArrangedSubview(relatedButton)
        
        view.addSubview(headerStackView)
        view.addSubview(containerView)
		view.addSubview(imageView)
        view.addSubview(titleStackView)
        view.addSubview(playbackStackView)
        view.addSubview(loadingIndicator)
        view.addSubview(sliderStackView)
        view.addSubview(controlsStackView)
        view.addSubview(lyricStackView)
		
		var actions: [UIAction] = []
		for speedMode in PlayerStore.State.SpeedMode.allCases {
			let action = UIAction(title: speedMode.title, image: store.speedMode.title == speedMode.title ? UIImage(systemName: "checkmark") : nil) { _ in
				self.store.send(.speedModeChanged(speedMode))
				self.updateRateMenuState()
			}
			
			actions.append(action)
		}
		
		let menu = UIMenu(title: "Playback Speed", children: actions)
		
		rateButton.menu = menu
    }
    
    private func setupLayoutContraints() {
        let defaultPadding: CGFloat = 30.0
        let innerSpacing: CGFloat = 20.0
        let defaultHeight: CGFloat = 44.0
        
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: defaultPadding),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -defaultPadding),
            headerStackView.heightAnchor.constraint(equalToConstant: defaultHeight),
            
            dismissButton.widthAnchor.constraint(equalToConstant: defaultHeight),
            moreButton.widthAnchor.constraint(equalToConstant: defaultHeight),
            
            containerView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: innerSpacing),
            containerView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1.0),
			
			imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
			imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            titleStackView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: innerSpacing),
            titleStackView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
            titleStackView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor),
            
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            artistLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            playbackStackView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: innerSpacing),
            playbackStackView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
            playbackStackView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor),
            playbackStackView.bottomAnchor.constraint(equalTo: sliderStackView.topAnchor, constant: -innerSpacing),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: playbackStackView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: playbackStackView.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 60),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 60),
            
            sliderStackView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
            sliderStackView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor),
            sliderStackView.heightAnchor.constraint(equalToConstant: defaultHeight / 2),
            sliderStackView.bottomAnchor.constraint(equalTo: controlsStackView.topAnchor, constant: -innerSpacing),
            
            currentTimeLabel.widthAnchor.constraint(equalToConstant: defaultHeight),
            durationLabel.widthAnchor.constraint(equalToConstant: defaultHeight),
            
            controlsStackView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
            controlsStackView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor),
            controlsStackView.heightAnchor.constraint(equalToConstant: defaultHeight),
            controlsStackView.bottomAnchor.constraint(equalTo: lyricStackView.topAnchor, constant: -innerSpacing),
            
            lyricStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            lyricStackView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
            lyricStackView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor),
            lyricStackView.heightAnchor.constraint(equalToConstant: defaultHeight),
        ])
    }
	
	private func updateRateMenuState() {
		rateButton.menu?.children.forEach { action in
			if let action = action as? UIAction {
				action.image = store.speedMode.title == action.title ? UIImage(systemName: "checkmark") : nil
			}
		}
	}
}

// MARK: - Actions

extension PlayerViewController {
    
    @objc private func dismissButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    @objc private func togglePlayPause(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		store.send(.togglePlayPauseButtonTapped)
    }
    
    @objc private func prevButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		store.send(.previousButtonTapped)
    }
    
    @objc private func nextButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		store.send(.nextButtonTapped)
    }
    
    @objc private func shuffleButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		store.send(.shuffleButtonTapped)
    }
    
    @objc private func repeatButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		store.send(.repeatButtonTapped)
    }
    
    @objc private func rateButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		
        sender.hero.id = "playbackSpeed"
        sender.hero.modifiers = [.fade, .useGlobalCoordinateSpace, .useOptimizedSnapshot]
        
        let playbackSpeedVC = PlaybackSpeedViewController()
        playbackSpeedVC.hero.isEnabled = true
        playbackSpeedVC.tableView.hero.id = "playbackSpeed"
        playbackSpeedVC.hero.modalAnimationType = .fade
        playbackSpeedVC.modalPresentationStyle = .fullScreen
        
        present(playbackSpeedVC, animated: true)
    }
    
    @objc private func timerButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        sender.hero.id = "sleepTimerTable"
        sender.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
		
		let sleepTimer = store.scope(state: \.sleepTimer, action: \.sleepTimer)
        let sleepTimerVC = SleepTimerViewController(store: sleepTimer)
        sleepTimerVC.hero.isEnabled = true
        sleepTimerVC.tableView.hero.id = "sleepTimerTable"
        sleepTimerVC.hero.modalAnimationType = .fade
        sleepTimerVC.modalPresentationStyle = .fullScreen
        
        present(sleepTimerVC, animated: true)
    }
    
    @objc private func moreButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		
		var playableWitnesses: [PlayableWitness] = []
		
		for i in 1..<5 {
			let bundleName = "sample_track_\(i)"
			let thumbnailURL = URL(string: "https://picsum.photos/id/\(i * 2)/1024")
			let ext = i % 4 == 0 ? "mp4" : "mp3"
			if let bundleURL = Bundle.main.url(forResource: bundleName, withExtension: ext) {
				let playableWitness = PlayableWitness(id: bundleName, title: "Sample Track \(i)", artist: "Artist \(i)", thumbnailURL: thumbnailURL, url: bundleURL)
				playableWitnesses.append(playableWitness)
			}
		}
		
		store.send(.setTracks(playableWitnesses, 0))
		
		/*
        let titleId = "more"
        sender.hero.id = titleId
        sender.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
        
        let moreVC = MoreViewController()
        moreVC.hero.isEnabled = true
        moreVC.tableView.hero.id = titleId
        moreVC.hero.modalAnimationType = .fade
        moreVC.modalPresentationStyle = .fullScreen
        
        present(moreVC, animated: true)
		*/
    }
    
    @objc private func equalizerButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let titleId = "equalizerTitle"
        sender.hero.id = titleId
        sender.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
		let equalizerStore = store.scope(state: \.equalizerStore, action: \.equalizerStore)
		let equalizerVC = EqualizerViewController(store: equalizerStore)
        equalizerVC.hero.isEnabled = true
        equalizerVC.collectionView.hero.id = titleId
        equalizerVC.hero.modalAnimationType = .fade
        equalizerVC.modalPresentationStyle = .fullScreen
        
        present(equalizerVC, animated: true)
    }
    
    @objc private func upnextButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        sender.isSelected.toggle()
        
        UIView.transition(with: headerStackView, duration: 0.3) {
            self.switchModeControl.alpha = sender.isSelected ? 0 : 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.switchModeControl.isHidden = sender.isSelected
            }
        }
    }
    
    @objc private func lyricsButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        sender.isSelected.toggle()
    }
    
    @objc private func relatedButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        sender.isSelected.toggle()
    }
	
	@objc private func sliderTouchUp(_ sender: UISlider) {
		UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		store.send(.sliderTouchedUp(sender.value))
	}
	
	@objc private func sliderTouchDown(_ sender: UISlider) {
		UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		store.send(.sliderTouchedDown)
	}
	
	@objc private func switchModeValueChanged(_ sender: UISegmentedControl) {
		UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		if let playMode = MediaPlayerClient.PlayMode(rawValue: sender.selectedSegmentIndex) {
			store.send(.playModeChanged(playMode))
		}
	}
}

struct PlayerViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
			PlayerViewController(store: Store(initialState: PlayerStore.State()) {
				PlayerStore()
			})
        }
    }
}
