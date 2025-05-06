//
//  CustomHostingController.swift
//  Example
//
//  Created by Thanh Hai Khong on 19/3/25.
//

import ComposableArchitecture
import TCAFeatureAction
import SwiftUI
import Hero

public final class CustomHostingController<Content: View, State, Action>: UIHostingController<Content> {
    
    private let store: Store<State, Action>
    
    public init(store: Store<State, Action>, @ViewBuilder content: (Store<State, Action>) -> Content) {
        self.store = store
        
        super.init(rootView: content(store))
        setupGestures()
        
        #if DEBUG
        print("🚀 CustomHostingController initialized with Content type: \(Content.self)")
        #endif
    }
        
    @MainActor @available(*, unavailable)
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            print("🏬 Has dismiss method: \(hasDismissMethod(Action.self))")
            dismiss(animated: true, completion: nil)
            
        case .changed:
            Hero.shared.update(translation.y / view.bounds.height)
            
        default:
            let velocity = gesture.velocity(in: view)
            if ((translation.y + velocity.y) / view.bounds.height) > 0.5 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
    }
    
    func hasDismissMethod(_ type: Any.Type) -> Bool {
        guard let featureActionType = type as? (any TCAFeatureAction).Type else {
            return false
        }
        let mirror = Mirror(reflecting: featureActionType)
        return mirror.children.contains { $0.label == "dismiss" }
    }
}
