//
//  MediaPlayerViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 7/5/25.
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
import AVKit

class MediaPlayerViewController: UIViewController {
	
	private let store: StoreOf<MediaPlayerStore>
	
	public init(store: StoreOf<MediaPlayerStore>) {
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
		store.send(.initializeNowPlaying)
		
		upnextView.didReorder = { [weak self] items in
			guard let `self` = self else {
				return
			}

			self.store.send(.didReorderTracks(items))
		}
		
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
			
			let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.mediumLargeSymbol
			let playImage = UIImage(systemName: "play.fill", withConfiguration: configuration)
			let pauseImage = UIImage(systemName: "pause.fill", withConfiguration: configuration)
			
			UIView.animate(withDuration: 0.3) {
				self.playPauseButton.setImage(self.store.isPlaying ? pauseImage : playImage, for: .normal)
				self.titleLabel.text = self.store.currentItem?.title ?? "Unknown"
				self.artistLabel.text = self.store.currentItem?.artist ?? "Unknown"
				self.imageView.image = self.store.thumbnailImage
				
				if self.store.isLoading {
					self.loadingIndicator.startAnimating()
					self.playPauseButton.alpha = 0
				} else {
					self.loadingIndicator.stopAnimating()
					self.playPauseButton.alpha = 1
				}
			}
		}
		
		observe { [weak self] in
			guard let `self` = self else {
				return
			}
			
			UIView.transition(with: self.shuffleButton, duration: 0.3, options: [.transitionFlipFromTop]) {
				self.shuffleButton.tintColor = self.store.shuffleMode == .on ? .redPink : .secondaryLabel
			}
		}
		
		observe { [weak self] in
			guard let `self` = self else {
				return
			}
			
			UIView.transition(with: self.repeatButton, duration: 0.3, options: [.transitionFlipFromTop]) {
				self.repeatButton.setImage(UIImage(systemName: self.store.repeatMode == .one ? "repeat.1" : "repeat", withConfiguration: UIImage.SymbolConfiguration.smallSymbol), for: .normal)
				self.repeatButton.tintColor = self.store.repeatMode == .off ? .secondaryLabel : .redPink
			}
		}
		
		observe { [weak self] in
			guard let `self` = self else {
				return
			}
			
			UIView.animate(withDuration: 0.5) {
				self.imageView.isHidden = self.store.playMode == .video
				self.equalizerButton.tintColor = self.store.equalizerStore.isEnabled ? .redPink : .secondaryLabel
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
				configuration.baseForegroundColor = .secondaryLabel
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
			configuration.baseForegroundColor = self.store.speedMode == .normal ? .secondaryLabel : .redPink
			configuration.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
			
			UIView.transition(with: self.rateButton, duration: 0.3, options: [.transitionFlipFromTop]) {
				self.rateButton.configuration = configuration
			}
		}
		
		observe { [weak self] in
			guard let `self` = self else {
				return
			}
			
			self.upnextView.configureView(self.store.upnexts)
		}
		
		NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main) { notification in
			let currentRoute = AVAudioSession.sharedInstance().currentRoute
			for output in currentRoute.outputs {
				if output.portType == .airPlay ||
					output.portType == .bluetoothA2DP ||
					output.portType == .bluetoothLE ||
					output.portType == .bluetoothHFP ||
					output.portType == .usbAudio {
					UIView.animate(withDuration: 0.5) {
						self.airplayButton.tintColor = .redPink
					}
				} else {
					UIView.animate(withDuration: 0.5) {
						self.airplayButton.tintColor = .secondaryLabel
					}
				}
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
		imageView.layer.cornerRadius = 5
		imageView.image = UIImage(named: "sample_artwork")
		return imageView
	}()
	
	private lazy var dismissButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		
		var configuration = UIButton.Configuration.plain()
		configuration.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration.smallSymbol)
		configuration.baseForegroundColor = .redPink
		configuration.imagePadding = 4
		configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20)
		
		button.configuration = configuration
		button.addTarget(self, action: #selector(dismissButtonTapped(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var moreButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		
		var configuration = UIButton.Configuration.plain()
		configuration.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration.smallSymbol)
		configuration.baseForegroundColor = .redPink
		configuration.imagePadding = 4
		configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
		
		button.configuration = configuration
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
	
	private lazy var contentView: UIView  = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var containerView: UIView  = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .systemGray5
		view.layer.cornerRadius = 10
		view.layer.masksToBounds = true
		return view
	}()
	
	private lazy var upnextView: UpnextView = {
		let view = UpnextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 10
		view.layer.masksToBounds = true
		return view
	}()
	
	private lazy var lyricsView: LyricsView = {
		let view = LyricsView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 10
		view.layer.masksToBounds = true
		return view
	}()
	
	private lazy var relatedView: RelatedView = {
		let view = RelatedView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 10
		view.layer.masksToBounds = true
		return view
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "You belong with me"
		label.font = UIFont.preferredFont(forTextStyle: .headline, weight: .semibold)
		label.textAlignment = .left
		label.textColor = .label
		return label
	}()
	
	private lazy var captionLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Up Next"
		label.font = UIFont.preferredFont(forTextStyle: .headline, weight: .semibold)
		label.textAlignment = .center
		label.textColor = .redPink
		return label
	}()
	
	private lazy var artistLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Taylor Swift"
		label.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .regular)
		label.textAlignment = .left
		label.textColor = .secondaryLabel
		return label
	}()
	
	private lazy var currentTimeLabel: UILabel  = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "02:20"
		label.font = UIFont.preferredFont(forTextStyle: .footnote)
		label.textAlignment = .left
		label.textColor = .label
		return label
	}()
	
	private lazy var durationLabel: UILabel  = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "04:41"
		label.font = UIFont.preferredFont(forTextStyle: .footnote)
		label.textAlignment = .right
		label.textColor = .label
		return label
	}()
	
	private lazy var favoriteButton: UIButton = {
		let button = UIButton()
		let config: UIImage.Configuration = UIImage.SymbolConfiguration.smallSymbol
		let image = UIImage(systemName: "heart", withConfiguration: config)
		let selectedImage = UIImage(systemName: "heart.fill", withConfiguration: config)
		button.setImage(image, for: .normal)
		button.setImage(selectedImage, for: .selected)
		button.tintColor = .secondaryLabel
		button.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var playPauseButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.mediumLargeSymbol
		let image = UIImage(systemName: "play.fill", withConfiguration: configuration)
		button.setImage(image, for: .normal)
		button.tintColor = .black
		button.addTarget(self, action: #selector(togglePlayPause(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var prevButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.smallMediumSymbol
		let image = UIImage(systemName: "backward.fill", withConfiguration: configuration)
		button.setImage(image, for: .normal)
		button.tintColor = .black
		button.addTarget(self, action: #selector(prevButtonTapped(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var nextButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.smallMediumSymbol
		let image = UIImage(systemName: "forward.fill", withConfiguration: configuration)
		button.setImage(image, for: .normal)
		button.tintColor = .black
		button.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var shuffleButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.smallSymbol
		let image = UIImage(systemName: "shuffle", withConfiguration: configuration)
		button.setImage(image, for: .normal)
		button.tintColor = .secondaryLabel
		button.addTarget(self, action: #selector(shuffleButtonTapped(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var repeatButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.smallSymbol
		let image = UIImage(systemName: "repeat", withConfiguration: configuration)
		button.setImage(image, for: .normal)
		button.tintColor = .secondaryLabel
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
		let image = UIImage(systemName: "alarm", withConfiguration: config)
		button.tintColor = .label
		var configuration = UIButton.Configuration.plain()
		configuration.image = image
		configuration.baseForegroundColor = .redPink
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
		button.tintColor = .secondaryLabel
		button.addTarget(self, action: #selector(equalizerButtonTapped(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var airplayButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		let configuration: UIImage.Configuration = UIImage.SymbolConfiguration.smallSymbol
		let image = UIImage(systemName: "airplay.audio", withConfiguration: configuration)
		button.setImage(image, for: .normal)
		button.tintColor = .secondaryLabel
		button.addTarget(self, action: #selector(airplayButtonTapped(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var upnextButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.configuration = buttonConfiguration(imageName: "text.insert", title: "Up Next")
		button.addTarget(self, action: #selector(upnextButtonTapped(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var lyricButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.configuration = buttonConfiguration(imageName: "quote.bubble", title: "Lyrics")
		button.addTarget(self, action: #selector(lyricsButtonTapped(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var relatedButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.configuration = buttonConfiguration(imageName: "rectangle.stack.badge.play", title: "Related")
		button.addTarget(self, action: #selector(relatedButtonTapped(_:)), for: .touchUpInside)
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
		slider.maximumTrackTintColor = .secondaryLabel
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
	
	private lazy var infoStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.distribution = .fill
		stackView.alignment = .center
		stackView.spacing = 8
		return stackView
	}()
	
	private lazy var titleStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.alignment = .leading
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
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.alignment = .fill
		stackView.spacing = 8
		return stackView
	}()
	
	private lazy var timeStackView: UIStackView = {
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

extension MediaPlayerViewController {
	
	private func setupViews() {
		view.backgroundColor = UIColor(hex: "F2F2F7")
		upnextView.alpha = 0.0
		lyricsView.alpha = 0.0
		relatedView.alpha = 0.0
		captionLabel.alpha = 0.0
		
		let routePickerView = AVRoutePickerView()
		routePickerView.translatesAutoresizingMaskIntoConstraints = false
		routePickerView.alpha = 0.0
		airplayButton.addSubview(routePickerView)
		
		NSLayoutConstraint.activate([
			routePickerView.centerXAnchor.constraint(equalTo: airplayButton.centerXAnchor),
			routePickerView.centerYAnchor.constraint(equalTo: airplayButton.centerYAnchor),
			routePickerView.widthAnchor.constraint(equalTo: airplayButton.widthAnchor),
			routePickerView.heightAnchor.constraint(equalTo: airplayButton.heightAnchor)
		])
		
		headerStackView.addArrangedSubview(dismissButton)
		headerStackView.addArrangedSubview(captionLabel)
		headerStackView.addArrangedSubview(moreButton)
		
		titleStackView.addArrangedSubview(titleLabel)
		titleStackView.addArrangedSubview(artistLabel)
		
		titleLabel.setContentHuggingPriority(.required, for: .vertical) // Hug content tightly
		titleLabel.setContentCompressionResistancePriority(.required, for: .vertical) // Resist shrinking
		titleLabel.numberOfLines = 1 // Allow multiline, but rely on intrinsic size
		
		artistLabel.setContentHuggingPriority(.required, for: .vertical)
		artistLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		artistLabel.numberOfLines = 1
		
		playbackStackView.addArrangedSubview(shuffleButton)
		playbackStackView.addArrangedSubview(prevButton)
		playbackStackView.addArrangedSubview(playPauseButton)
		playbackStackView.addArrangedSubview(nextButton)
		playbackStackView.addArrangedSubview(repeatButton)
		playbackStackView.setContentHuggingPriority(.defaultLow, for: .vertical) // Encourage playbackStackView to stretch vertically
		
		infoStackView.addArrangedSubview(imageView)
		infoStackView.addArrangedSubview(titleStackView)
		infoStackView.addArrangedSubview(UIView())
		infoStackView.addArrangedSubview(favoriteButton)
		
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
		
		timeStackView.addArrangedSubview(currentTimeLabel)
		timeStackView.addArrangedSubview(UIView())
		timeStackView.addArrangedSubview(durationLabel)
		
		sliderStackView.addArrangedSubview(timeSlider)
		sliderStackView.addArrangedSubview(timeStackView)
		
		controlsStackView.addArrangedSubview(equalizerButton)
		controlsStackView.addArrangedSubview(timerButton)
		controlsStackView.addArrangedSubview(airplayButton)
		
		lyricStackView.addArrangedSubview(upnextButton)
		lyricStackView.addArrangedSubview(lyricButton)
		lyricStackView.addArrangedSubview(relatedButton)
		
		view.addSubview(headerStackView)
		view.addSubview(contentView)
		view.addSubview(containerView)
		view.addSubview(upnextView)
		view.addSubview(lyricsView)
		view.addSubview(relatedView)
		view.addSubview(infoStackView)
		view.addSubview(playbackStackView)
		view.addSubview(loadingIndicator)
		view.addSubview(sliderStackView)
		view.addSubview(controlsStackView)
		view.addSubview(lyricStackView)
	}
	
	private func setupLayoutContraints() {
		let defaultPadding: CGFloat = 20.0
		let innerSpacing: CGFloat = 20.0
		let defaultHeight: CGFloat = 44.0
		
		NSLayoutConstraint.activate([
			headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: defaultPadding),
			headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -defaultPadding),
			headerStackView.heightAnchor.constraint(equalToConstant: defaultHeight),
			
			dismissButton.widthAnchor.constraint(equalToConstant: defaultHeight),
			moreButton.widthAnchor.constraint(equalToConstant: defaultHeight),
			
			contentView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: innerSpacing / 2),
			contentView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor),
			contentView.bottomAnchor.constraint(equalTo: infoStackView.topAnchor, constant: -innerSpacing),
			
			upnextView.topAnchor.constraint(equalTo: contentView.topAnchor),
			upnextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			upnextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			upnextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			
			lyricsView.topAnchor.constraint(equalTo: contentView.topAnchor),
			lyricsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			lyricsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			lyricsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			
			relatedView.topAnchor.constraint(equalTo: contentView.topAnchor),
			relatedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			relatedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			relatedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			
			containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
			containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			
			infoStackView.bottomAnchor.constraint(equalTo: sliderStackView.topAnchor, constant: -innerSpacing),
			infoStackView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
			infoStackView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor),
			
			imageView.widthAnchor.constraint(equalToConstant: 60),
			imageView.heightAnchor.constraint(equalToConstant: 48),
			
			titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
			artistLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
			
			sliderStackView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
			sliderStackView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor),
			sliderStackView.heightAnchor.constraint(equalToConstant: defaultHeight),
			sliderStackView.bottomAnchor.constraint(equalTo: playbackStackView.topAnchor, constant: -innerSpacing),
			
			playbackStackView.topAnchor.constraint(equalTo: sliderStackView.bottomAnchor, constant: innerSpacing),
			playbackStackView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
			playbackStackView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor),
			playbackStackView.bottomAnchor.constraint(equalTo: controlsStackView.topAnchor, constant: -innerSpacing),
			
			loadingIndicator.centerXAnchor.constraint(equalTo: playbackStackView.centerXAnchor),
			loadingIndicator.centerYAnchor.constraint(equalTo: playbackStackView.centerYAnchor),
			loadingIndicator.widthAnchor.constraint(equalToConstant: 60),
			loadingIndicator.heightAnchor.constraint(equalToConstant: 60),
			
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
	
	private func buttonConfiguration(imageName: String, title: String) -> UIButton.Configuration {
		var configuration = UIButton.Configuration.plain()
		configuration.image = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration.tinySymbol)
		configuration.title = title
		configuration.baseForegroundColor = .label
		configuration.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: UIFont.preferredFont(forTextStyle: .headline, weight: .semibold)]))
		configuration.imagePadding = 4
		configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
		configuration.baseBackgroundColor = .redPink
		return configuration
	}
}

// MARK: - Actions

extension MediaPlayerViewController {
	
	@objc private func dismissButtonTapped(_ sender: UIButton) {
		UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		store.send(.dismissButtonTapped)
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
				let playableWitness = PlayableWitness(id: bundleName, title: "Sample Track \(i)", artist: "Artist \(i)", thumbnailURL: thumbnailURL, url: URL(string: "https://rr1---sn-i5ovpuj-i5oe.googlevideo.com/videoplayback?expire=1747388354&ei=YrMmaM_XEcfU2roP_IuE8AQ&ip=202.93.156.46&id=o-AEGKH5NE8iO1cq5fCGIJAdv-diXRjWFEgg4ZrCXaOQaH&itag=250&source=youtube&requiressl=yes&xpc=EgVo2aDSNQ%3D%3D&met=1747366754%2C&mh=7E&mm=31%2C29&mn=sn-i5ovpuj-i5oe%2Csn-i3b7knzl&ms=au%2Crdu&mv=m&mvi=1&pcm2cms=yes&pl=24&rms=au%2Cau&gcr=vn&initcwndbps=2162500&bui=AecWEAYkwo5dJ7QVahlhN2Zp-AS9AuoQrgvh8bKTY5dSvjvDpUzk3Q_JLQmfV5ZiEZjjcW74wf-WmmVR&spc=wk1kZjS_UNIj&vprv=1&svpuc=1&mime=audio%2Fwebm&rqh=1&gir=yes&clen=1369585&dur=173.401&lmt=1729642612264438&mt=1747366378&fvip=5&keepalive=yes&c=IOS&txp=4532434&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cxpc%2Cgcr%2Cbui%2Cspc%2Cvprv%2Csvpuc%2Cmime%2Crqh%2Cgir%2Cclen%2Cdur%2Clmt&sig=AJfQdSswRQIgZcPDBSfxmDIaLFUrM6iOwBNPUizwy4ESQZxJ0tKe-pECIQCD7_v3bt1NyG7qiZ_5diMn3zjiKwNdMOitkXQiQJkooQ%3D%3D&lsparams=met%2Cmh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpcm2cms%2Cpl%2Crms%2Cinitcwndbps&lsig=ACuhMU0wRQIgaCEV_QeRk8oB76ESfb3xM3CSfIzyWYZ--zMP5s5AvkYCIQCh4L-jJh47FNvT2hPFs-qHr4tgGLkyHCDgNM3xnRjjXQ%3D%3D"))
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
	
	@objc private func airplayButtonTapped(_ sender: UIButton) {
		UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		guard let routePickerView = sender.subviews.first(where: { $0 is AVRoutePickerView }) as? AVRoutePickerView else {
			return
		}
		
		for view: UIView in routePickerView.subviews {
			if let button = view as? UIButton {
				button.sendActions(for: .touchUpInside)
				break
			}
		}
	}
	
	@objc private func favoriteButtonTapped(_ sender: UIButton) {
		UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		sender.isSelected.toggle()
		
		UIView.transition(with: sender, duration: 0.3, options: [.transitionFlipFromLeft]) {
			sender.tintColor = sender.isSelected ? .redPink : .secondaryLabel
		}
		
		store.send(.favoriteButtonTapped)
	}
	
	@objc private func upnextButtonTapped(_ sender: UIButton) {
		UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		sender.isSelected.toggle()
		
		UIView.animate(withDuration: 0.3) {
			self.upnextView.alpha = sender.isSelected ? 1.0 : 0.0
			self.lyricsView.alpha = 0.0
			self.relatedView.alpha = 0.0
			self.containerView.alpha = sender.isSelected ? 0.0 : 1.0
			self.captionLabel.alpha = sender.isSelected ? 1.0 : 0.0
			self.captionLabel.text = "Up Next"
			
			self.lyricButton.isSelected = false
			self.relatedButton.isSelected = false
		}
	}
	
	@objc private func lyricsButtonTapped(_ sender: UIButton) {
		UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		sender.isSelected.toggle()
		
		UIView.animate(withDuration: 0.3) {
			self.lyricsView.alpha = sender.isSelected ? 1.0 : 0.0
			self.upnextView.alpha = 0.0
			self.relatedView.alpha = 0.0
			self.containerView.alpha = sender.isSelected ? 0.0 : 1.0
			self.captionLabel.alpha = sender.isSelected ? 1.0 : 0.0
			self.captionLabel.text = "Lyrics"
			
			self.upnextButton.isSelected = false
			self.relatedButton.isSelected = false
		}
	}
	
	@objc private func relatedButtonTapped(_ sender: UIButton) {
		UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		sender.isSelected.toggle()
		
		UIView.animate(withDuration: 0.3) {
			self.relatedView.alpha = sender.isSelected ? 1.0 : 0.0
			self.upnextView.alpha = 0.0
			self.lyricsView.alpha = 0.0
			self.containerView.alpha = sender.isSelected ? 0.0 : 1.0
			self.captionLabel.alpha = sender.isSelected ? 1.0 : 0.0
			self.captionLabel.text = "Related"
			
			self.upnextButton.isSelected = false
			self.lyricButton.isSelected = false
		}
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

struct MediaPlayerViewController_Previews: PreviewProvider {
	static var previews: some View {
		UIViewControllerPreview {
			MediaPlayerViewController(store: Store(initialState: MediaPlayerStore.State()) {
				MediaPlayerStore()
			})
		}
	}
}
