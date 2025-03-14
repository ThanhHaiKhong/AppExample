// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

private enum Constants {
    static let gestureProgressFactor: CGFloat = 0.01
}

public class InteractiveModalTransition: UIPercentDrivenInteractiveTransition {
    
    public var ignoreTouchInViews: [UIView] = []
    
    var interactionInProgress = false
    var shouldCompleteTransition = false
    
    @MainActor var onProgressUpdate: ((_ progress: CGFloat) -> Void)?
    @MainActor var onCancel: (() -> Void)?
    @MainActor var onFinish: (() -> Void)?
    
    private var impactFeedbackgenerator: UIImpactFeedbackGenerator?
    private var currentTranslationDirection: CGPoint = .zero
    private weak var viewController: UIViewController!
    private var transitionGestures: [UIGestureRecognizer] = []
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
        setupGestures(in: viewController.view)
        setupImpactGenerator()
    }
    
    public override func update(_ progress: CGFloat) {
        let clampedProgress = min(1.0, progress)
        if clampedProgress >= 1.0 && !shouldCompleteTransition {
            shouldCompleteTransition = true
            impact()
        } else if clampedProgress < 1.0 && shouldCompleteTransition {
            shouldCompleteTransition = false
            impact()
        }
        onProgressUpdate?(clampedProgress)
        super.update(clampedProgress)
    }
    
    public override func cancel() {
        resetState()
        onCancel?()
        super.cancel()
    }
    
    public func endTransition() {
        resetState()
        onFinish?()
    }
    
    public override func finish() {
        super.finish()
    }
    
    private func setupGestures(in view: UIView) {
        let edgeDirections: [UIRectEdge] = [.left, .right]
        for edge in edgeDirections {
            let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeGesture(_:)))
            edgePanGesture.edges = edge
            edgePanGesture.delegate = self
            view.addGestureRecognizer(edgePanGesture)
            transitionGestures.append(edgePanGesture)
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        transitionGestures.append(panGesture)
        
        #if targetEnvironment(macCatalyst)
        if #available(macCatalyst 13.4, *) {
            panGesture.allowedScrollTypesMask = .continuous
        }
        #endif
    }
    
    @objc private func handleEdgeGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        handleGesture(gestureRecognizer)
    }
    
    @objc private func handleSwipeGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            for disablingView in ignoreTouchInViews {
                if disablingView.bounds.contains(gestureRecognizer.location(in: disablingView)) {
                    gestureRecognizer.state = .failed
                    return
                }
            }
        }
        handleGesture(gestureRecognizer)
    }
    
    private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view?.superview else { return }
        let translation = gestureRecognizer.translation(in: view)
        let xPos = translation.x
        let yPos = translation.y
        if currentTranslationDirection == . zero {
            currentTranslationDirection = CGPoint(
                x: translation.x / norm(translation),
                y: translation.y / norm(translation)
            )
        }
        var progress = (xPos * currentTranslationDirection.x + yPos * currentTranslationDirection.y)
        progress *= Constants.gestureProgressFactor
        progress = max(progress, 0.0)
        
        if gestureRecognizer.state != .ended && shouldCompleteTransition {
            gestureRecognizer.state = .ended
            return
        }
        
        switch gestureRecognizer.state {
        case .began:
            prepareImpactGeneratorForImpact()
            interactionInProgress = true
            viewController.navigationController?.popViewController(animated: true)
        case .changed:
            update(progress)
        case .cancelled:
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition {
                endTransition()
            } else {
                cancel()
            }
        default:
            break
        }
    }
    
    private func norm(_ point: CGPoint) -> CGFloat {
        let norm = sqrt(pow(point.x, 2) + pow(point.y, 2))
        return norm != 0 ? norm : 0.00001
    }
    
    private func setupImpactGenerator() {
        DispatchQueue.main.async {
            self.impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
        }
    }
    
    private func prepareImpactGeneratorForImpact() {
        DispatchQueue.main.async {
            self.impactFeedbackgenerator?.prepare()
        }
    }
    
    private func impact() {
        DispatchQueue.main.async {
            self.impactFeedbackgenerator?.impactOccurred()
        }
    }
    
    private func resetState() {
        currentTranslationDirection = .zero
    }
}

extension InteractiveModalTransition: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return transitionGestures.contains(otherGestureRecognizer)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIScreenEdgePanGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
}
