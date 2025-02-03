//
//  File.swift
//  ImageMagick
//
//  Created by Thanh Hai Khong on 19/11/24.
//

import ImageMagickObjC
import CoreGraphics
import UIKit

@available(iOS 13.0.0, *)
public struct SharpenFilter: Presetable, Equatable {
    private let radius: Double
    private let sigma: Double
    
    public init(radius: Double, sigma: Double) {
        self.radius = radius
        self.sigma = sigma
    }
    
    public func apply(to wand: MagickWand) async throws {
        if MagickSharpenImage(wand, radius, sigma) == MagickFalse {
            throw ImagePresetError.unknownError("Failed to apply sharpen filter")
        }
    }
    
    public static func == (lhs: SharpenFilter, rhs: SharpenFilter) -> Bool {
        lhs.radius == rhs.radius && lhs.sigma == rhs.sigma
    }
}

@available(iOS 13.0.0, *)
public struct UnsharpMaskFilter: Presetable, Equatable {
    private let radius: Double
    private let sigma: Double
    private let amount: Double
    private let threshold: Double
    
    public init(radius: Double, sigma: Double, amount: Double, threshold: Double) {
        self.radius = radius
        self.sigma = sigma
        self.amount = amount
        self.threshold = threshold
    }
    
    public func apply(to wand: MagickWand) async throws {
        if MagickUnsharpMaskImage(wand, radius, sigma, amount, threshold) == MagickFalse {
            throw ImagePresetError.unknownError("Failed to apply unsharp mask")
        }
    }
    
    public static func == (lhs: UnsharpMaskFilter, rhs: UnsharpMaskFilter) -> Bool {
        lhs.radius == rhs.radius && lhs.sigma == rhs.sigma && lhs.amount == rhs.amount && lhs.threshold == rhs.threshold
    }
}

@available(iOS 13.0.0, *)
public struct ThresholdFilter: Presetable, Equatable {
    private let threshold: Double
    
    public init(threshold: Double) {
        self.threshold = threshold
    }
    
    public func apply(to wand: MagickWand) async throws {
        if MagickThresholdImage(wand, threshold) == MagickFalse {
            throw ImagePresetError.unknownError("Failed to apply threshold filter")
        }
    }
    
    public static func == (lhs: ThresholdFilter, rhs: ThresholdFilter) -> Bool {
        lhs.threshold == rhs.threshold
    }
}

@available(iOS 13.0.0, *)
public enum FilterType: String, CaseIterable, Presetable, Equatable {
    case undefined, point, box, triangle, hermite, hanning, hamming, blackman, gaussian, quadratic, cubic, catrom, mitchell, jinc, sinc, sincFast, kaiser, welsh, parzen, bohman, bartlett, lagrange, lanczos, lanczosSharp, lanczos2, lanczos2Sharp, robidoux, robidouxSharp, cosine, spline, lanczosRadius
    
    var magickFilterType: FilterTypes {
        switch self {
        case .undefined: return UndefinedFilter
        case .point: return PointFilter
        case .box: return BoxFilter
        case .triangle: return TriangleFilter
        case .hermite: return HermiteFilter
        case .hanning: return HanningFilter
        case .hamming: return HammingFilter
        case .blackman: return BlackmanFilter
        case .gaussian: return GaussianFilter
        case .quadratic: return QuadraticFilter
        case .cubic: return CubicFilter
        case .catrom: return CatromFilter
        case .mitchell: return MitchellFilter
        case .jinc: return JincFilter
        case .sinc: return SincFilter
        case .sincFast: return SincFastFilter
        case .kaiser: return KaiserFilter
        case .welsh: return WelshFilter
        case .parzen: return ParzenFilter
        case .bohman: return BohmanFilter
        case .bartlett: return BartlettFilter
        case .lagrange: return LagrangeFilter
        case .lanczos: return LanczosFilter
        case .lanczosSharp: return LanczosSharpFilter
        case .lanczos2: return Lanczos2Filter
        case .lanczos2Sharp: return Lanczos2SharpFilter
        case .robidoux: return RobidouxFilter
        case .robidouxSharp: return RobidouxSharpFilter
        case .cosine: return CosineFilter
        case .spline: return SplineFilter
        case .lanczosRadius: return LanczosRadiusFilter
        }
    }
    
    public func apply(to wand: MagickWand) async throws {
        if MagickResizeImage(wand, 0, 0, magickFilterType, 1.0) == MagickFalse {
            throw ImagePresetError.unknownError("Failed to apply filter \(self.rawValue)")
        }
    }
    
    public static func == (lhs: FilterType, rhs: FilterType) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

