// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@available(iOS 16.0, *)
enum BackgroundType {
    case color(Color)
    case material(Material)
}

extension View {
    @available(iOS 16.0, *)
    public func circleMaterialStyleWithoutBackground(_ size: CGFloat = 44, isSelected: Bool) -> some View {
        modifier(CircleStyleWithoutBackgroundModifier(size: size, isSelected: isSelected))
    }
    
    @available(iOS 16.0, *)
    public func circleMaterialStyle(_ size: CGFloat = 44) -> some View {
        modifier(CircleStyleModifier(size: size))
    }
    
    @available(iOS 16.0, *)
    public func circleColorStyle(_ size: CGFloat = 44, backgroundColor: Color) -> some View {
        modifier(CircleColorStyleModifier(size: size, backgroundColor: backgroundColor))
    }
    
    @available(iOS 16.0, *)
    public func squareStyle() -> some View {
        modifier(SquareStyleModifier())
    }
    
    @available(iOS 16.0, *)
    public func capsuleStyle() -> some View {
        modifier(CapsuleStyleModifier())
    }
    
    @available(iOS 16.0, *)
    public func backgroundCapsule(_ backgroundColor: Color) -> some View {
        modifier(BackgroundCapsuleStyleModifier(backgroundColor: backgroundColor))
    }
    
    @available(iOS 16.0, *)
    public func squareHorizontalStretchStyle() -> some View {
        modifier(SquareHorizontalStretchStyleModifier())
    }
    
    @available(iOS 16.0, *)
    public func squareVerticalStretchStyle() -> some View {
        modifier(SquareVerticalStretchStyleModifier())
    }
    
    public var screenSize: CGSize {
        guard let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.bounds.size else {
            return .zero
        }
        return size
    }
    
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

@available(iOS 16.0, *)
struct CircleStyleWithoutBackgroundModifier: ViewModifier {
    let size: CGFloat
    let isSelected: Bool
    func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .font(.system(.title3).weight(.semibold))
            .foregroundColor(isSelected ? .accentColor : .black)
    }
}


@available(iOS 16.0, *)
struct CircleStyleModifier: ViewModifier {
    let size: CGFloat
    func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .font(.system(.headline).weight(.semibold))
            .foregroundColor(.white)
            .background(.thinMaterial)
            .clipShape(.circle)
    }
}

@available(iOS 16.0, *)
struct CircleColorStyleModifier: ViewModifier {
    let size: CGFloat
    let backgroundColor: Color
    func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .font(.system(.headline).weight(.semibold))
            .foregroundColor(.white)
            .background(backgroundColor)
            .clipShape(.circle)
    }
}

@available(iOS 16.0, *)
struct SquareStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 44, height: 44)
            .font(.system(.headline).weight(.semibold))
            .foregroundColor(.white)
            .background(.thinMaterial)
            .clipShape(.rect(cornerRadius: 5))
    }
}

@available(iOS 16.0, *)
struct SquareHorizontalStretchStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .font(.system(.headline).weight(.semibold))
            .foregroundColor(.white)
            .background(.thinMaterial)
            .clipShape(.rect(cornerRadius: 5))
    }
}

@available(iOS 16.0, *)
struct SquareVerticalStretchStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 44)
            .frame(maxHeight: .infinity)
            .font(.system(.headline).weight(.semibold))
            .foregroundColor(.white)
            .background(.thinMaterial)
            .clipShape(.rect(cornerRadius: 5))
    }
}

@available(iOS 16.0, *)
struct CapsuleStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .font(.system(.headline).weight(.semibold))
            .foregroundColor(.white)
            .background(.thinMaterial)
            .clipShape(.capsule)
    }
}

@available(iOS 16.0, *)
struct BackgroundCapsuleStyleModifier: ViewModifier {
    let backgroundColor: Color
    func body(content: Content) -> some View {
        content
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .font(.system(.headline).weight(.semibold))
            .symbolRenderingMode(.monochrome)
            .foregroundColor(.white)
            .background(backgroundColor)
            .clipShape(.capsule)
    }
}

private struct RoundedCorner: Shape {
    let radius: CGFloat
    let corners: UIRectCorner
    
    init(radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
