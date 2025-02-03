//
//  SingleImageProcessor+Effects.swift
//  ImageMagick
//
//  Created by Thanh Hai Khong on 25/11/24.
//

import ImageMagickObjC
import UIKit
import SwiftUICore

@available(iOS 13.0.0, *)
public struct TransposeEffect: Presetable, Equatable {
    private let id: String = "transpose"
    public init() {}
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickTransposeImage(wand) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to apply transpose effect")
        }
    }
    
    public static func == (lhs: TransposeEffect, rhs: TransposeEffect) -> Bool {
        lhs.id == rhs.id
    }
}

@available(iOS 13.0.0, *)
public struct TransverseEffect: Presetable, Equatable {
    private let id: String = "transverse"
    public init() {}
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickTransverseImage(wand) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to apply transverse effect")
        }
    }
    
    public static func == (lhs: TransverseEffect, rhs: TransverseEffect) -> Bool {
        lhs.id == rhs.id
    }
}

@available(iOS 13.0.0, *)
public struct VignetteEffect: Presetable, Equatable {
    private let radius: Double
    private let sigma: Double
    private let x: Int
    private let y: Int
    
    public init(radius: Double, sigma: Double, x: Int, y: Int) {
        self.radius = radius
        self.sigma = sigma
        self.x = x
        self.y = y
    }
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickVignetteImage(wand, radius, sigma, x, y) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to apply vignette effect")
        }
    }
    
    public static func == (lhs: VignetteEffect, rhs: VignetteEffect) -> Bool {
        lhs.radius == rhs.radius && lhs.sigma == rhs.sigma && lhs.x == rhs.x && lhs.y == rhs.y
    }
}

@available(iOS 13.0.0, *)
public struct WaveEffect: Presetable, Equatable {
    private let amplitude: Double
    private let wavelength: Double
    
    public init(amplitude: Double, wavelength: Double) {
        self.amplitude = amplitude
        self.wavelength = wavelength
    }
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickWaveImage(wand, amplitude, wavelength) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to apply wave effect")
        }
    }
    
    public static func == (lhs: WaveEffect, rhs: WaveEffect) -> Bool {
        lhs.amplitude == rhs.amplitude && lhs.wavelength == rhs.wavelength
    }
}

@available(iOS 13.0.0, *)
public struct SpreadEffect: Presetable, Equatable {
    private let amount: Double
    
    public init(amount: Double) {
        self.amount = amount
    }
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickSpreadImage(wand, amount) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to apply spread effect")
        }
    }
    
    public static func == (lhs: SpreadEffect, rhs: SpreadEffect) -> Bool {
        lhs.amount == rhs.amount
    }
}

@available(iOS 13.0.0, *)
public struct StripEffect: Presetable, Equatable {
    private let id: String = "strip"
    public init() {}
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickStripImage(wand) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to strip image")
        }
    }
    
    public static func == (lhs: StripEffect, rhs: StripEffect) -> Bool {
        lhs.id == rhs.id
    }
}

@available(iOS 13.0.0, *)
public struct SwirlEffect: Presetable, Equatable {
    private let degrees: Double
    
    public init(degrees: Double) {
        self.degrees = degrees
    }
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickSwirlImage(wand, degrees) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to apply swirl effect")
        }
    }
    
    public static func == (lhs: SwirlEffect, rhs: SwirlEffect) -> Bool {
        lhs.degrees == rhs.degrees
    }
}

@available(iOS 13.0.0, *)
public struct TintEffect: Presetable, Equatable {
    private let tintColor: UIColor
    private let threshold: UIColor
    
    public init(tintColor: UIColor, threshold: UIColor) {
        self.tintColor = tintColor
        self.threshold = threshold
    }
    
    public func apply(to wand: MagickWand) async throws {
        let tintPixel = NewPixelWand()
        let thresholdPixel = NewPixelWand()
        
        // Chuyển UIColor thành RGB và set giá trị cho PixelWand
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        threshold.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Set the color to PixelWand
        PixelSetRed(tintPixel, red)
        PixelSetGreen(tintPixel, green)
        PixelSetBlue(tintPixel, blue)
        PixelSetAlpha(tintPixel, alpha)
        
        PixelSetRed(thresholdPixel, red)
        PixelSetGreen(thresholdPixel, green)
        PixelSetBlue(thresholdPixel, blue)
        PixelSetAlpha(thresholdPixel, alpha)
        
        if MagickTintImage(wand, tintPixel, thresholdPixel) == MagickFalse {
            DestroyPixelWand(tintPixel)
            DestroyPixelWand(thresholdPixel)
            throw ImagePresetError.unknownError("Failed to apply tint effect")
        } else {
            DestroyPixelWand(tintPixel)
            DestroyPixelWand(thresholdPixel)
        }
    }
    
    public static func == (lhs: TintEffect, rhs: TintEffect) -> Bool {
        lhs.threshold == rhs.threshold
    }
}

@available(iOS 13.0.0, *)
public struct ShadowEffect: Presetable, Equatable {
    private let sigma: Double
    private let angle: Double
    private let xOffset: Int
    private let yOffset: Int
    
    public init(sigma: Double, angle: Double, xOffset: Int, yOffset: Int) {
        self.sigma = sigma
        self.angle = angle
        self.xOffset = xOffset
        self.yOffset = yOffset
    }
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickShadowImage(wand, sigma, angle, Int(xOffset), Int(yOffset)) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to apply shadow effect")
        }
    }
    
    public static func == (lhs: ShadowEffect, rhs: ShadowEffect) -> Bool {
        lhs.sigma == rhs.sigma && lhs.angle == rhs.angle && lhs.xOffset == rhs.xOffset && lhs.yOffset == rhs.yOffset
    }
}

@available(iOS 13.0.0, *)
public struct ShadeEffect: Presetable, Equatable {
    private let isLight: Bool
    private let angle: Double
    private let sigma: Double
    
    public init(isLight: Bool, angle: Double, sigma: Double) {
        self.isLight = isLight
        self.angle = angle
        self.sigma = sigma
    }
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickShadeImage(wand, isLight ? MagickTrue : MagickFalse, angle, sigma) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to apply shade effect")
        }
    }
    
    public static func == (lhs: ShadeEffect, rhs: ShadeEffect) -> Bool {
        lhs.isLight == rhs.isLight && lhs.angle == rhs.angle && lhs.sigma == rhs.sigma
    }
}

@available(iOS 13.0.0, *)
public struct SketchEffect: Presetable, Equatable {
    private let radius: Double
    private let sigma: Double
    private let angle: Double
    
    public init(radius: Double, sigma: Double, angle: Double) {
        self.radius = radius
        self.sigma = sigma
        self.angle = angle
    }
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickSketchImage(wand, radius, sigma, angle) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to apply sketch effect")
        }
    }
    
    public static func == (lhs: SketchEffect, rhs: SketchEffect) -> Bool {
        lhs.radius == rhs.radius && lhs.sigma == rhs.sigma && lhs.angle == rhs.angle
    }
}

@available(iOS 13.0.0, *)
public struct ShaveEffect: Presetable, Equatable {
    private let width: Int
    private let height: Int
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickShaveImage(wand, width, height) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to apply shave effect")
        }
    }
    
    public static func == (lhs: ShaveEffect, rhs: ShaveEffect) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
    }
}

@available(iOS 13.0.0, *)
public struct ShearEffect: Presetable, Equatable {
    private let shearX: Double
    private let shearY: Double
    private let color: UIColor
    
    public init(shearX: Double, shearY: Double, color: UIColor) {
        self.shearX = shearX
        self.shearY = shearY
        self.color = color
    }
    
    public func apply(to wand: MagickWand) async throws {
        let pixelWand = NewPixelWand()
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        PixelSetRed(pixelWand, red)
        PixelSetGreen(pixelWand, green)
        PixelSetBlue(pixelWand, blue)
        PixelSetAlpha(pixelWand, alpha)
        
        guard MagickShearImage(wand, pixelWand, shearX, shearY) == MagickTrue else {
            DestroyPixelWand(pixelWand)
            throw ImagePresetError.unknownError("Failed to apply shear effect")
        }
        
        DestroyPixelWand(pixelWand)
    }
    
    public static func == (lhs: ShearEffect, rhs: ShearEffect) -> Bool {
        lhs.shearX == rhs.shearX && lhs.shearY == rhs.shearY && lhs.color == rhs.color
    }
}

@available(iOS 13.0.0, *)
public struct SolarizeEffect: Presetable, Equatable {
    private let threshold: Double
    
    public init(threshold: Double) {
        self.threshold = threshold
    }
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickSolarizeImage(wand, threshold) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to apply solarize effect")
        }
    }
    
    public static func == (lhs: SolarizeEffect, rhs: SolarizeEffect) -> Bool {
        lhs.threshold == rhs.threshold
    }
}

@available(iOS 13.0.0, *)
public struct SigmoidalContrastEffect: Presetable, Equatable {
    private let contrast: Double
    private let midpoint: Double
    
    public init(contrast: Double, midpoint: Double) {
        self.contrast = contrast
        self.midpoint = midpoint
    }
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickSigmoidalContrastImage(wand, MagickTrue, contrast, midpoint) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to apply sigmoidal contrast effect")
        }
    }
    
    public static func == (lhs: SigmoidalContrastEffect, rhs: SigmoidalContrastEffect) -> Bool {
        lhs.contrast == rhs.contrast && lhs.midpoint == rhs.midpoint
    }
}


public actor TransposeActor {
    
    public func apply(to wand: MagickWand) async throws {
        guard MagickTransposeImage(wand) == MagickTrue else {
            throw ImagePresetError.unknownError("Failed to apply transpose effect")
        }
    }
}
