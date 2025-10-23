// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Preview cho UIViewController

#if os(iOS)
public struct UIViewControllerPreview<VC: UIViewController>: UIViewControllerRepresentable {
    private let builder: () -> VC
    
    public init(_ builder: @escaping () -> VC) {
        self.builder = builder
    }
    
    public func makeUIViewController(context: Context) -> VC {
        return builder()
    }
    
    public func updateUIViewController(_ uiViewController: VC, context: Context) {
        
    }
}

// MARK: - Preview cho UIView

public struct UIViewPreview<V: UIView>: UIViewRepresentable {
    private let builder: () -> V
    
    public init(_ builder: @escaping () -> V) {
        self.builder = builder
    }
    
    public func makeUIView(context: Context) -> V {
        return builder()
    }
    
    public func updateUIView(_ uiView: V, context: Context) {
        
    }
}
#endif
