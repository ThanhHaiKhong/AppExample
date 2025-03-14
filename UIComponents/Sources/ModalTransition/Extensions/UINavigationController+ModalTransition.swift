//
//  ModalTransitionNavigationDelegate.swift
//  UIComponents
//
//  Created by Thanh Hai Khong on 13/3/25.
//

import UIKit

public extension ModalTransitionNavigationDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push, let fromVC = fromVC as? TransitionPresenter, let toVC = toVC as? TransitionableView, fromVC.presentingView != nil, toVC.isModalTransitionEnabled {
            return ModalCardAnimator(operation: operation, interactor: toVC.modalInteractor)
        } else if operation == .pop, toVC is TransitionPresenter, let fromVC = fromVC as? TransitionableView, fromVC.isModalTransitionEnabled {
            return ModalCardAnimator(operation: operation, interactor: fromVC.modalInteractor)
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let interactor = (animationController as? ModalCardAnimator)?.interactor else { return nil }
        return interactor.interactionInProgress ? interactor : nil
    }
}

public class ModalNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push, let fromVC = fromVC as? TransitionPresenter, let toVC = toVC as? TransitionableView, fromVC.presentingView != nil, toVC.isModalTransitionEnabled {
            return ModalCardAnimator(operation: operation, interactor: toVC.modalInteractor)
        } else if operation == .pop, toVC is TransitionPresenter, let fromVC = fromVC as? TransitionableView, fromVC.isModalTransitionEnabled {
            return ModalCardAnimator(operation: operation, interactor: fromVC.modalInteractor)
        }
        return nil
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let interactor = (animationController as? ModalCardAnimator)?.interactor else { return nil }
        return interactor.interactionInProgress ? interactor : nil
    }
}
