// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct FlipView<Front: View, Back: View>: View {
    private var visibleSide: FlipViewSide
    @ViewBuilder private let front: Front
    @ViewBuilder private let back: Back
    
    public init(visibleSide: FlipViewSide, @ViewBuilder front: () -> Front, @ViewBuilder back: () -> Back) {
        self.visibleSide = visibleSide
        self.front = front()
        self.back = back()
    }
    
    public var body: some View {
        ZStack {
            front
                .modifier(FlipModifier(side: .front, visibleSide: visibleSide))
            back
                .modifier(FlipModifier(side: .back, visibleSide: visibleSide))
        }
    }
}

public enum FlipViewSide: Equatable {
    case front
    case back
    
    public mutating func toggle() {
        self = self == .front ? .back : .front
    }
}

public struct FlipModifier: AnimatableModifier {
    public var side: FlipViewSide
    public var flipProgress: Double
    
    public init(side: FlipViewSide, visibleSide: FlipViewSide) {
        self.side = side
        self.flipProgress = visibleSide == .front ? 0 : 1
    }
    
    nonisolated public var animatableData: Double {
        get { flipProgress }
        set { flipProgress = newValue }
    }
    
    public var visible: Bool {
        switch side {
        case .front:
            return flipProgress <= 0.5
        case .back:
            return flipProgress > 0.5
        }
    }
    
    public var scale: CGFloat {
        switch side {
        case .front:
            return 1.0
        case .back:
            return -1.0
        }
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(visible ? 1 : 0)
                .accessibility(hidden: !visible)
        }
        .scaleEffect(x: scale, y: 1.0)
        .rotation3DEffect(.degrees(flipProgress * -180), axis: (x: 0.0, y: 1.0, z: 0.0), perspective: 0.5)
    }
}

extension Animation {
    public static let openCard = Animation.spring(response: 0.45, dampingFraction: 0.9)
    public static let closeCard = Animation.spring(response: 0.35, dampingFraction: 1)
    public static let flipCard = Animation.spring(response: 0.35, dampingFraction: 0.7)
}
