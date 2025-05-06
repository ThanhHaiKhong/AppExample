//
//  MetalView.swift
//  UIComponents
//
//  Created by Thanh Hai Khong on 15/4/25.
//

#if os(iOS) || os(visionOS)
import UIKit

public class MetalView: UIView {

    public var renderer: Renderer?

    @objc public static override var layerClass: AnyClass {
        CAMetalLayer.self
    }

    public var metalLayer: CAMetalLayer {
        layer as! CAMetalLayer
    }

    public override func draw(_ rect: CGRect) {
        render()
    }

    public override func draw(_ layer: CALayer, in ctx: CGContext) {
        render()
    }

    public override func display(_ layer: CALayer) {
        render()
    }

    public func render() {
        guard let renderer else { return }
        renderer.draw(to: metalLayer)
    }

    public func resizeDrawable() {

        var newSize = bounds.size
        newSize.width *= contentScaleFactor
        newSize.height *= contentScaleFactor

        if newSize.width <= 0 || newSize.height <= 0 {
            return
        }

        if newSize.width == metalLayer.drawableSize.width &&
            newSize.height == metalLayer.drawableSize.height {
            return
        }

        metalLayer.drawableSize = newSize

        setNeedsDisplay()
    }

    @objc public override var frame: CGRect {
        get { super.frame }
        set {
            super.frame = newValue
            resizeDrawable()
        }
    }

    @objc public override func layoutSubviews() {
        super.layoutSubviews()
        resizeDrawable()
    }

    @objc public override var bounds: CGRect {
        get { super.bounds }
        set {
            super.bounds = newValue
            resizeDrawable()
        }
    }

}
#endif
