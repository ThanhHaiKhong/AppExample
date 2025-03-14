// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

public class ModalCardAnimator: NSObject, @unchecked Sendable {
    public let operationType: UINavigationController.Operation
    public let interactor: InteractiveModalTransition?
    
    public init(operation: UINavigationController.Operation,
                interactor: InteractiveModalTransition?
    ) {
        self.operationType = operation
        self.interactor = interactor
    }
}

extension ModalCardAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        guard let presentedView = transitionContext?.viewController(forKey: .to) as? TransitionableView else { return 0 }
        switch operationType {
        case .push:
            return max(presentedView.transitionConfig.presentResize, presentedView.transitionConfig.presentDuration)
        case .pop:
            return max(presentedView.transitionConfig.dismissResize, presentedView.transitionConfig.dismissDuration)
        default:
            return 0
        }
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch operationType {
        case .push:
            presentAnimation(transitionContext)
        case .pop:
            dismissAnimation(transitionContext)
        default:
            break
        }
    }
}

extension ModalCardAnimator {
    @MainActor
    internal func presentAnimation( _ transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let fromCardViewPresenter = transitionContext.viewController(forKey: .from) as? TransitionPresenter,
              let toCardPresentedView = transitionContext.viewController(forKey: .to) as? TransitionableView,
              let fromStatusBarStyle = transitionContext.viewController(forKey: .from)?.preferredStatusBarStyle,
              let toStatusBarStyle = transitionContext.viewController(forKey: .to)?.preferredStatusBarStyle,
              let toView = transitionContext.view(forKey: .to)
        else {
            return
        }
        
        let transitionProperties = toCardPresentedView.transitionConfig
        let toFrame = toView.frame
        let transitionContainer = UIView(frame: .zero)
        transitionContainer.addSubview(toView)
        container.addSubview(transitionContainer)
        
        let fromCard = fromCardViewPresenter.presentingView ?? UIView()
        toCardPresentedView.willPresentBegin(from: fromCard)
        
        let absoluteFromCardFrame = (fromCard.superview ?? fromCard).convert(fromCard.frame, to: container)
        transitionContainer.frame = absoluteFromCardFrame
        toView.frame.size = absoluteFromCardFrame.size
        toView.frame.origin = .zero
        transitionContainer.layoutIfNeeded()
        transitionContainer.transform = fromCard.transform
        toView.alpha = fromCard.alpha
        fromCard.alpha = 0
        
        let yDiff = toFrame.origin.y - absoluteFromCardFrame.origin.y
        let xDiff = toFrame.origin.x - absoluteFromCardFrame.origin.x
        
        var statusBarStyleUpdated = false
        toCardPresentedView.updateStatusBar(fromStatusBarStyle)
        
        var animationStartTime: CFTimeInterval = CACurrentMediaTime()
        var firstAnimation = true
        let animationDuration: CFTimeInterval = min(transitionProperties.presentDuration, transitionProperties.presentResize)
        let animationDidUpdate = Action {
            if firstAnimation {
                animationStartTime = CACurrentMediaTime()
                firstAnimation = false
            }
            
            let animationProgress = min(1, (CACurrentMediaTime() - animationStartTime) / animationDuration)
            let curvedProgress = min((log10(1 + animationProgress * 29) / log10(30))*1.4, 1)
            
            DispatchQueue.main.async {
                fromCardViewPresenter.dismissProgress(CGFloat(curvedProgress))
                toCardPresentedView.presentProgress(CGFloat(curvedProgress))
                if curvedProgress > 0.8 && !statusBarStyleUpdated {
                    statusBarStyleUpdated = true
                    UIView.animate(
                        withDuration: transitionProperties.presentStatusBar,
                        animations: {
                            toCardPresentedView.updateStatusBar(toStatusBarStyle)
                        }
                    )
                }
            }
        }
        
        let displayLink: CADisplayLink = CADisplayLink(target: animationDidUpdate, selector: #selector(animationDidUpdate.selector))
        
        let completionHandler: (Bool) -> Void = { _ in
            container.addSubview(toView)
            transitionContainer.removeFromSuperview()
            toView.layoutIfNeeded()
            fromCard.alpha = 1
            displayLink.invalidate()
            fromCardViewPresenter.willDismissEnd()
            toCardPresentedView.willPresentEnd()
            fromCardViewPresenter.updateStatusBar(fromStatusBarStyle)
            toCardPresentedView.updateStatusBar(toStatusBarStyle)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        var positionAnimatorHandler: ((Bool) -> ())?
        var sizeAnimatorHandler: ((Bool) -> ())?
        
        if transitionProperties.presentDuration > transitionProperties.presentResize {
            positionAnimatorHandler = completionHandler
        } else {
            sizeAnimatorHandler = completionHandler
        }
        
        fromCardViewPresenter.didDismissBegin()
        toCardPresentedView.didPresentBegin()
        
        animationStartTime = CACurrentMediaTime()
        displayLink.add(to: RunLoop.current, forMode: .common)
        
        UIView.animate(withDuration: 0.2) {
            toView.alpha = 1
        }
        
        UIView.animate(
            withDuration: transitionProperties.presentDuration,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0,
            options: [.curveEaseIn],
            animations: {
                transitionContainer.frame.origin.y += yDiff
                transitionContainer.frame.origin.x += xDiff
            },
            completion: positionAnimatorHandler
        )
        
        UIView.animate(
            withDuration: transitionProperties.presentResize,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.curveEaseIn],
            animations: {
                transitionContainer.transform = .identity
                transitionContainer.frame.size = toFrame.size
                transitionContainer.layoutIfNeeded()
            },
            completion: sizeAnimatorHandler
        )
    }
    
    @MainActor
    internal func dismissAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard
            let fromCardPresentedView = transitionContext.viewController(forKey: .from) as? TransitionableView,
            let toCardViewPresenter = transitionContext.viewController(forKey: .to) as? TransitionPresenter,
            let fromStatusBarStyle = transitionContext.viewController(forKey: .from)?.preferredStatusBarStyle,
            let toStatusBarStyle = transitionContext.viewController(forKey: .to)?.preferredStatusBarStyle,
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else {
            return
        }
        
        let transitionProperties = fromCardPresentedView.transitionConfig
        let originFrame = fromView.frame
        
        toCardViewPresenter.willPresentBegin()
        fromCardPresentedView.willDismissBegin()
        
        container.addSubview(toView)
        container.addSubview(fromView)
        
        var preTransitionProgress: CGFloat = 0.0
        
        toCardViewPresenter.updateStatusBar(fromStatusBarStyle)
        
        let startTransitionBlock = { [weak fromView, weak fromCardPresentedView, weak toCardViewPresenter, weak transitionContext, weak interactor] in
            guard let fromView = fromView, let transitionContext = transitionContext else { return }
            guard let fromCardPresentedView = fromCardPresentedView, let toCardViewPresenter = toCardViewPresenter else { return }
            
            toCardViewPresenter.didPresentBegin()
            fromCardPresentedView.didDismissBegin()
            
            let animationStartTime: CFTimeInterval = CACurrentMediaTime()
            let animationDuration: CFTimeInterval = min(transitionProperties.dismissDuration, transitionProperties.dismissResize)
            let animationDidUpdate = Action {
                let animationProgress = min(CGFloat((CACurrentMediaTime() - animationStartTime) / animationDuration), 1)
                let curvedProgress = min((log10(1 + animationProgress * 29) / log10(30))*1.4, 1)
                let globalProgress = (1 - preTransitionProgress) * (min(curvedProgress, 1))
                
                DispatchQueue.main.async {
                    fromCardPresentedView.dismissProgress(globalProgress + preTransitionProgress)
                    toCardViewPresenter.presentProgress(globalProgress + preTransitionProgress)
                }
            }
            
            let displayLink: CADisplayLink = CADisplayLink(target: animationDidUpdate, selector: #selector(animationDidUpdate.selector))
            displayLink.add(to: RunLoop.current, forMode: .common)
            
            guard let toCardView = toCardViewPresenter.presentingView else {
                UIView.animate(
                    withDuration: transitionProperties.dismissDuration,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: [.curveEaseIn],
                    animations: {
                        toCardViewPresenter.updateStatusBar(toStatusBarStyle)
                        fromView.clipsToBounds = true
                        fromView.frame.size = CGSize(width: 108, height: 108)
                        fromView.layoutIfNeeded()
                        fromView.transform = CGAffineTransform(translationX: container.frame.width/2-108/2, y: container.frame.height)
                    },
                    completion: { _ in
                        toCardViewPresenter.willPresentEnd()
                        fromCardPresentedView.willDismissEnd()
                        fromCardPresentedView.updateStatusBar(fromStatusBarStyle)
                        toCardViewPresenter.updateStatusBar(toStatusBarStyle)
                        fromView.removeFromSuperview()
                        displayLink.invalidate()
                        interactor?.finish()
                        transitionContext.completeTransition(true)
                    }
                )
                return
            }
            
            toCardView.alpha = 0
            
            let destinationFrame = CGRect(
                origin: (toCardView.superview ?? toCardView).convert(toCardView.frame.origin, to: toView),
                size: toCardView.frame.size
            )
            
            let yDiff = destinationFrame.origin.y - originFrame.origin.y
            let xDiff = destinationFrame.origin.x - originFrame.origin.x
            
            let completionHandler: (Bool) -> Void = { _ in
                toCardView.alpha = 1
                fromView.layer.shadowOpacity = 0
                toCardViewPresenter.willPresentEnd()
                fromCardPresentedView.willDismissEnd()
                
                UIView.animate(withDuration: transitionProperties.dismissFade, animations: {
                    fromView.alpha = 0
                }, completion: { _ in
                    fromCardPresentedView.updateStatusBar(fromStatusBarStyle)
                    toCardViewPresenter.updateStatusBar(toStatusBarStyle)
                    fromView.removeFromSuperview()
                    displayLink.invalidate()
                    interactor?.finish()
                    transitionContext.completeTransition(true)
                })
            }
            
            var positionAnimatorHandler: ((Bool) -> ())?
            var sizeAnimatorHandler: ((Bool) -> ())?
            
            if transitionProperties.dismissDuration > transitionProperties.dismissResize {
                positionAnimatorHandler = completionHandler
            } else {
                sizeAnimatorHandler = completionHandler
            }
            
            UIView.animate(
                withDuration: transitionProperties.dismissStatusBar, delay: 0,
                options: .allowUserInteraction, animations: {
                    toCardViewPresenter.updateStatusBar(toStatusBarStyle)
                }
            )
            
            UIView.animate(
                withDuration: transitionProperties.dismissDuration,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0,
                options: [.curveEaseInOut],
                animations: {
                    fromView.transform = CGAffineTransform(translationX: 0, y: yDiff)
                },
                completion: positionAnimatorHandler
            )
            
            UIView.animate(
                withDuration: transitionProperties.dismissResize,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: [.curveEaseInOut],
                animations: {
                    fromView.frame.size = destinationFrame.size
                    fromView.layoutIfNeeded()
                    fromView.transform = fromView.transform.concatenating(CGAffineTransform(translationX: xDiff, y: 0))
                },
                completion: sizeAnimatorHandler
            )
        }
        
        if let interactor = interactor, interactor.interactionInProgress {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
            blurView.backgroundColor = transitionProperties.backgroundColor
            blurView.frame = fromView.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            toView.addSubview(blurView)
            
            interactor.onFinish = {
                UIView.animate(withDuration: transitionProperties.dismissBlur, animations: {
                    blurView.effect = .none
                    blurView.backgroundColor = .clear
                }, completion: { bool in
                    blurView.removeFromSuperview()
                })
                
                DispatchQueue.main.async {
                    startTransitionBlock()
                }
            }
            
            interactor.onCancel = { [weak fromView, weak fromCardPresentedView, weak toCardViewPresenter, weak transitionContext] in
                fromCardPresentedView?.willPresentCancel()
                toCardViewPresenter?.willPresentCancel()
                
                UIView.animate(
                    withDuration: transitionProperties.cancelResize,
                    delay: 0,
                    usingSpringWithDamping: 0.9,
                    initialSpringVelocity: 0,
                    options: [.curveEaseInOut],
                    animations: {
                        fromView?.transform = .identity
                    }, completion: { _ in
                        fromCardPresentedView?.updateStatusBar(fromStatusBarStyle)
                        toCardViewPresenter?.updateStatusBar(toStatusBarStyle)
                        blurView.removeFromSuperview()
                        transitionContext?.completeTransition(false)
                    }
                )
            }
            
            let pi = CGFloat.pi
            let stepLength: CGFloat = 3
            let stepFactor: CGFloat = 100/(50 - stepLength)
            
            interactor.onProgressUpdate = { [weak fromView, weak fromCardPresentedView, weak toCardViewPresenter] progress in
                let curvedProgress = (atan(stepFactor * (progress - 1 / stepFactor)) * 2 / pi + 0.5)
                preTransitionProgress = min(curvedProgress, 1) * transitionProperties.dismissThreshold
                let scale = (1 - preTransitionProgress / 2)
                fromCardPresentedView?.dismissProgress(preTransitionProgress)
                toCardViewPresenter?.presentProgress(preTransitionProgress)
                fromView?.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        } else {
            DispatchQueue.main.async {
                startTransitionBlock()
            }
        }
    }
}
