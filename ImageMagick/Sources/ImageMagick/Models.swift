//
//  ImageMetadata.swift
//  ImageMagick
//
//  Created by Thanh Hai Khong on 19/11/24.
//

import Foundation
import MagickWand
import UIKit

@available(iOS 13.0.0, *)
public typealias MagickWand = OpaquePointer
public typealias MagickWandPointer = UnsafeMutablePointer<MagickWand>
public typealias MagickResolution = (xResolution: Double, yResolution: Double)
public typealias EstimatedFileSize = (original: String, compressed: String)
public typealias ProgressMonitorCallback = @convention(c) (UnsafePointer<CChar>?, MagickOffsetType, MagickSizeType, UnsafeMutableRawPointer?) -> MagickBooleanType

@available(iOS 13.0.0, *)
public protocol Presetable: Sendable {
    func apply(to wand: MagickWand) async throws
}

@available(iOS 13.0.0, *)
public enum ImagePresetError: Error {
    case invalidParameter(String)
    case unknownError(String)
}

@available(iOS 13.0.0, *)
public enum ImageFormat: String, Identifiable, CaseIterable, Sendable {
    case unknown = "UNKNOWN"
    case png = "PNG"
    case jpeg = "JPEG"
    case tiff = "TIFF"
    case bmp = "BMP"
    case gif = "GIF"
    case heic = "HEIC"
    case webp = "WEBP"
    case svg = "SVG"
    
    public var magickFormat: String {
        return self.rawValue
    }
    
    public var id: String {
        rawValue
    }
}

@available(iOS 13.0.0, *)
public enum ImageProcessorError: Error, LocalizedError {
    case invalidImagePath
    case failedToReadImage(String)
    case wandNotInitialized
    case wandNotContainImage
    case failedToApplyPreset(String)
    case failedToCloneWand
    case failedToGetUIImage
    case failedToSetImageFormat(String)
    case failedToWriteImage(String)
    case unknownError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidImagePath:
            return "The image path provided is invalid."
        case .failedToReadImage(let path):
            return "Failed to read the image at path: \(path)"
        case .wandNotInitialized:
            return "The wand is not initialized."
        case .wandNotContainImage:
            return "The wand does not contain an image."
        case .failedToApplyPreset(let reason):
            return "Failed to apply preset: \(reason)."
        case .failedToCloneWand:
            return "Failed to clone the current wand."
        case .failedToGetUIImage:
            return "Failed to get UIImage."
        case .failedToSetImageFormat(let format):
            return "Failed to set image format to \(format)."
        case .failedToWriteImage(let path):
            return "Failed to write image to path: \(path)"
        case .unknownError(let error):
            return "Unknown error: \(error)"
        }
    }
}

@available(iOS 13.0.0, *)
public struct Metadata: Sendable, Equatable {
    public struct ImageProperty: Identifiable, Equatable {
        public let name: String
        public let description: String
        public var indented: Bool = false
        public var id: String {
            name + description
        }
        
        public static func == (lhs: Metadata.ImageProperty, rhs: Metadata.ImageProperty) -> Bool {
            lhs.name == rhs.name && lhs.description == rhs.description
        }
    }
    
    public var basic: [String: String]
    public var device: [String: String]
    public var exif: [String: String] // Exchangable Image File Format
    public var gps: [String: String]
    public var colorProfile: [String: String]
    public var custom: [String: String]
    public var editing: [String: String]
    public var iptc: [String: String] // International Press Telecommunications Council
    public var file: [String: String]
    
    public static func == (lhs: Metadata, rhs: Metadata) -> Bool {
        lhs.basic == rhs.basic && lhs.device == rhs.device && lhs.exif == rhs.exif && lhs.gps == rhs.gps && lhs.colorProfile == rhs.colorProfile && lhs.custom == rhs.custom && lhs.editing == rhs.editing && lhs.iptc == rhs.iptc && lhs.file == rhs.file
    }
    
    public func toImageProperties() -> [ImageProperty] {
        var properties: [ImageProperty] = []
        if !basic.isEmpty {
            properties.append(.init(name: "Basic", description: ""))
            for (key, value) in basic {
                properties.append(.init(name: key, description: value, indented: true))
            }
        }
        
        if !device.isEmpty {
            properties.append(.init(name: "Device", description: ""))
            for (key, value) in device {
                properties.append(.init(name: key, description: value, indented: true))
            }
        }
        
        if !exif.isEmpty {
            properties.append(.init(name: "Exif", description: ""))
            for (key, value) in exif {
                properties.append(.init(name: key, description: value, indented: true))
            }
        }
        
        if !gps.isEmpty {
            properties.append(.init(name: "GPS", description: ""))
            for (key, value) in gps {
                properties.append(.init(name: key, description: value, indented: true))
            }
        }
        
        if !colorProfile.isEmpty {
            properties.append(.init(name: "Color Profile", description: ""))
            for (key, value) in colorProfile {
                properties.append(.init(name: key, description: value, indented: true))
            }
        }
        
        if !custom.isEmpty {
            properties.append(.init(name: "Custom", description: ""))
            for (key, value) in custom {
                properties.append(.init(name: key, description: value, indented: true))
            }
        }
        
        if !editing.isEmpty {
            properties.append(.init(name: "Editing", description: ""))
            for (key, value) in editing {
                properties.append(.init(name: key, description: value, indented: true))
            }
        }
        
        if !iptc.isEmpty {
            properties.append(.init(name: "Iptc", description: ""))
            for (key, value) in iptc {
                properties.append(.init(name: key, description: value, indented: true))
            }
        }
        
        if !file.isEmpty {
            properties.append(.init(name: "File", description: ""))
            for (key, value) in file {
                properties.append(.init(name: key, description: value, indented: true))
            }
        }

        
        return properties
    }
}

@available(iOS 13.0.0, *)
public struct CompressionInput: Sendable, CustomStringConvertible, Equatable {
    public let quality: Double
    public let percent: Double
    public let format: String
    
    public init(quality: Double, percent: Double, format: String) {
        self.quality = quality
        self.percent = percent
        self.format = format
    }
    
    public var description: String {
        """
        CompressionInput:
        - Quality: \(quality)
        - Percent: \(percent)
        - Format: \(format)
        """
    }
}

@available(iOS 13.0.0, *)
public struct CompressionResult: Sendable, CustomStringConvertible {
    public let originalSize: Int64
    public let compressedSize: Int64
    public let outputImage: UIImage
    
    public var description: String {
        """
        CompressionResult:
        - Original Image Size: \(originalSize)
        - Compressed Image Size: \(compressedSize)
        - Output Image: \(outputImage.debugDescription)
        """
    }
}

@available(iOS 13.0.0, *)
public struct SequenceCompressionResult: Sendable, Equatable, CustomStringConvertible {
    public let originalSize: Int64
    public let compressedSize: Int64
    public let outputPath: String
    public let status: Status
    
    public init(
        originalSize: Int64 = .zero,
        compressedSize: Int64 = .zero,
        outputPath: String = "",
        status: Status
    ) {
        self.originalSize = originalSize
        self.compressedSize = compressedSize
        self.outputPath = outputPath
        self.status = status
    }
    
    public enum Status: Sendable, Equatable, CustomStringConvertible {
        case success
        case failed(Error)
        
        public var description: String {
            switch self {
            case .success:
                return "Success"
            case .failed(let error):
                return "Failed: \(error)"
            }
        }
        
        public static func == (lhs: Status, rhs: Status) -> Bool {
            switch (lhs, rhs) {
            case (.success, .success):
                return true
            case (.failed(let lhsError), .failed(let rhsError)):
                return lhsError as NSError == rhsError as NSError
            default:
                return false
            }
        }
    }
    
    public var description: String {
        """
        CompressionResult:
        - Original Image Size: \(originalSize)
        - Compressed Image Size: \(compressedSize)
        - Output Path: \(outputPath)
        - Status: \(status)
        """
    }
}

public enum SequenceProgress: Sendable {
    case inProcessing(Double)
    case finished([SequenceCompressionResult])
}
