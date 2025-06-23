//
//  AutoHidingStackView.swift
//  UIComponents
//
//  Created by Thanh Hai Khong on 23/6/25.
//

import UIKit

public class AutoHidingStackView: UIStackView {
	
	private struct ViewObservation {
		weak var view: UIView?
		var observation: NSKeyValueObservation
	}
	
	private var observations: [ViewObservation] = []
	
	public override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		setupObservers()
		updateVisibility()
	}
	
	public override func addArrangedSubview(_ view: UIView) {
		super.addArrangedSubview(view)
		
		observe(view)
		updateVisibility()
	}
	
	public override func removeArrangedSubview(_ view: UIView) {
		super.removeArrangedSubview(view)
		
		removeObserver(for: view)
		updateVisibility()
	}
	
	private func setupObservers() {
		observations.forEach { $0.observation.invalidate() }
		observations = arrangedSubviews.map { observe($0) }
	}
	
	@discardableResult
	private func observe(_ view: UIView) -> ViewObservation {
		let obs = view.observe(\.isHidden, options: [.initial, .new]) { [weak self] _, _ in
			DispatchQueue.main.async {	
				self?.updateVisibility()
			}
		}
		let pair = ViewObservation(view: view, observation: obs)
		observations.append(pair)
		return pair
	}
	
	private func removeObserver(for view: UIView) {
		observations.removeAll { $0.view === view }
	}
	
	private func updateVisibility() {
		let hasVisibleSubview = arrangedSubviews.contains(where: { !$0.isHidden })
		self.isHidden = !hasVisibleSubview
	}
	
	deinit {
		observations.forEach { $0.observation.invalidate() }
	}
}
