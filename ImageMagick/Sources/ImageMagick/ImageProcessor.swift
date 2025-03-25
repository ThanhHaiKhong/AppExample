//
//  ImageProcessor.swift
//  ImageMagick
//
//  Created by Thanh Hai Khong on 7/1/25.
//

import ImageMagickObjC
import Foundation
import UIKit

@available(iOS 13.0.0, *)
public actor ImageProcessor {

    // MARK: - Properties
    
    private var wand: MagickWand
    private var imagePath: String?
    
    // MARK: - Singleton Instance
    
    public static let shared = ImageProcessor()

    // MARK: - Initialization
    
    private init() {
        MagickWandGenesis()
        self.wand = NewMagickWand()
        
        Task {
            try await deleteCompressedFilesInTempDirectory()
        }
    }
    
    // MARK: - Public Methods

    public func processingImage(_ path: String, input: CompressionInput) async throws -> CompressionResult {
        clearAllImages()
        try await loadImage(from: path, to: wand)
        setImagePathIfNeeded(path)
        
        let originalSize = getUncompressedFileSize(wand: wand)
        
        try await convertImage(wand, format: input.format)
        try await resizeImage(wand, percent: input.percent)
        try await compressImage(wand, quality: input.quality)
        
        let compressedSize = getUncompressedFileSize(wand: wand)
        let image = try await getUIImage(from: wand)
        let compresstionResult = CompressionResult(originalSize: originalSize, compressedSize: compressedSize, outputImage: image)

        return compresstionResult
    }
    
    public func getMetadata(from imagePath: String) async throws -> Metadata {
        let wand = try await cloneWand(wand)
        defer {
            DestroyMagickWand(wand)
        }
        
        try await loadImage(from: imagePath, to: wand)
        
        var metadata = Metadata(
            basic: [:],
            device: [:],
            exif: [:],
            gps: [:],
            colorProfile: [:],
            custom: [:],
            editing: [:],
            iptc: [:],
            file: [:]
        )
        
        metadata.basic = try await getBasicMetadata(wand)
        
        metadata.device["Make"] = getImageProperty(wand, "exif:Make")
        metadata.device["Model"] = getImageProperty(wand, "exif:Model")
        metadata.device["Software"] = getImageProperty(wand, "exif:Software")
        metadata.device["Lens Model"] = getImageProperty(wand, "exif:LensModel")
        metadata.device["Firmware"] = getImageProperty(wand, "exif:Firmware")
        
        metadata.exif["Date Time Original"] = getImageProperty(wand, "exif:DateTimeOriginal")
        metadata.exif["ISO"] = getImageProperty(wand, "exif:ISOSpeedRatings")
        metadata.exif["Shutter Speed"] = getImageProperty(wand, "exif:ShutterSpeedValue")
        metadata.exif["Aperture"] = getImageProperty(wand, "exif:FNumber")
        metadata.exif["Focal Length"] = getImageProperty(wand, "exif:FocalLength")
        
        metadata.gps["Latitude"] = getImageProperty(wand, "exif:GPSLatitude")
        metadata.gps["Longitude"] = getImageProperty(wand, "exif:GPSLongitude")
        metadata.gps["Altitude"] = getImageProperty(wand, "exif:GPSAltitude")
        
        metadata.colorProfile["Colorspace"] = getImageColorSpace(wand)
        
        metadata.iptc["Title"] = getImageProperty(wand, "iptc:Title")
        metadata.iptc["Caption"] = getImageProperty(wand, "iptc:Caption")
        
        metadata.editing["Date Modified"] = getImageProperty(wand, "exif:DateTimeDigitized")
        
        metadata.file["File Name"] = getFileName(imagePath)
        metadata.file["File Size"] = getFileSize(imagePath)
        metadata.file["Creation Date"] = getFileCreationDate(imagePath)
        
        return metadata
    }
    
    public func listAvailableImageFormats() async throws -> [String] {
        let listSupportedFormats = try await listSupportedFormats()
        let imageFormatsSet: Set<String> = ["JPEG", "JPG", "PNG", "GIF", "TIFF", "BMP", "ICO", "SVG", "PSD", "RAW", "DNG", "WEBP", "HEIC"]
        let imageFormats = listSupportedFormats.filter { imageFormatsSet.contains($0.uppercased()) }
        return imageFormats
    }
    
    public func cleanUp() async throws {
        clearAllImages()
        try await deleteCompressedFilesInTempDirectory()
    }
    
    public func getCompressedPath() async throws -> String {
        guard let path = imagePath else {
            throw ImageProcessorError.invalidImagePath
        }
        
        let outputPath = generateOutputPath(path)
        try removeFileAtPathIfNeeded(outputPath)
        
        try await writeImage(to: outputPath)
        
        return outputPath
    }

    // MARK: - Private Methods
    
    private func generateOutputPath(_ path: String) -> String {
        let fileName = getFileName(path)
        let fileExtension = (fileName as NSString).pathExtension
        let outputPath = path.replacingOccurrences(of: ".\(fileExtension)", with: "") + "_compressed.\(fileExtension)"
        return outputPath
    }
    
    private func removeFileAtPathIfNeeded(_ path: String) throws {
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(atPath: path)
        }
    }
    
    private func setImagePathIfNeeded(_ path: String) {
        if imagePath != path {
            imagePath = path
        }
    }

    private func saveBlob(wand: MagickWand) -> Data? {
        var blobLength: Int = 0
        if let blobPointer = MagickGetImageBlob(wand, &blobLength) {
            return Data(bytes: blobPointer, count: blobLength)
        }
        return nil
    }

    private func loadBlob(blob: Data) {
        blob.withUnsafeBytes { buffer in
            if let baseAddress = buffer.baseAddress {
                MagickReadImageBlob(wand, baseAddress, buffer.count)
            }
        }
    }
    
    private func writeImage(to path: String) async throws {
        guard MagickWriteImage(wand, path) != MagickFalse else {
            throw ImageProcessorError.failedToWriteImage("Failed to write image to \(path)")
        }
    }

    private func loadImage(from path: String, to wand: MagickWand) async throws {
        if MagickReadImage(wand, path) == MagickFalse {
            throw ImageProcessorError.failedToReadImage(path)
        }
    }
    
    private func clearAllImages() {
        ClearMagickWand(wand)
    }

    private func iterateFrames(process: (MagickWandPointer) -> Void) {
        MagickSetFirstIterator(wand) // Di chuyển tới frame đầu tiên
        repeat {
            process(&wand) // Gọi closure xử lý frame hiện tại
        } while MagickNextImage(wand) == MagickTrue
    }
    
    private func cloneWand(_ wand: MagickWand) async throws -> MagickWand {
        guard let clonedWand = CloneMagickWand(wand) else {
            throw ImageProcessorError.failedToCloneWand
        }
        return clonedWand
    }
}

@available(iOS 13.0.0, *)
extension ImageProcessor {
    
    private func getUIImage(from wand: MagickWand) async throws -> UIImage {
        var length: Int = 0
        guard let blob = MagickGetImageBlob(wand, &length) else {
            throw ImageProcessorError.failedToGetUIImage
        }
        
        let imageData = Data(bytes: blob, count: length)
        MagickRelinquishMemory(blob)
        
        guard let uiImage = UIImage(data: imageData) else {
            throw ImageProcessorError.failedToGetUIImage
        }
        
        return uiImage
    }
    
    private func getFrameCount() -> Int {
        return Int(MagickGetNumberImages(wand))
    }
    
    private func getBasicMetadata(_ wand: MagickWand) async throws -> [String: String] {
        [
            "Format": try getImageFormat(wand),
            "Width": String(getImageWidth(wand)),
            "Height": String(getImageHeight(wand)),
            "Resolution": "\(getImageResolution(wand).x) x \(getImageResolution(wand).y)",
            "Color Depth": String(getImageDepth(wand))
        ]
    }
    
    private func getImageProperty(_ wand: MagickWand, _ property: String) -> String? {
        guard let value = MagickGetImageProperty(wand, property) else { return nil }
        return String(cString: value)
    }
    
    private func getImageWidth(_ wand: MagickWand) -> Int {
        return Int(MagickGetImageWidth(wand))
    }
    
    private func getImageHeight(_ wand: MagickWand) -> Int {
        return Int(MagickGetImageHeight(wand))
    }
    
    private func getImageResolution(_ wand: MagickWand) -> (x: Double, y: Double) {
        var resolutionX: Double = 0
        var resolutionY: Double = 0
        MagickGetImageResolution(wand, &resolutionX, &resolutionY)
        return (resolutionX, resolutionY)
    }
    
    private func getImageDepth(_ wand: MagickWand) -> Int {
        return Int(MagickGetImageDepth(wand))
    }
    
    private func getImageFormat(_ wand: MagickWand) throws -> String {
        guard let format = MagickGetImageFormat(wand) else {
            throw ImageProcessorError.unknownError("Failed to get image format")
        }
        return String(cString: format)
    }
    
    private func compressionType(for imageFormat: String) -> CompressionType {
        switch imageFormat.lowercased() {
        case "jpeg", "jpg":
            return JPEGCompression
        case "jpeg2000":
            return JPEG2000Compression
        case "png":
            return ZipCompression
        case "tiff":
            return LZWCompression
        case "gif":
            return NoCompression
        case "bmp":
            return RLECompression
        case "dxt1":
            return DXT1Compression
        case "dxt3":
            return DXT3Compression
        case "dxt5":
            return DXT5Compression
        case "bzip":
            return BZipCompression
        case "fax":
            return FaxCompression
        case "group4":
            return Group4Compression
        case "losslessjpeg":
            return LosslessJPEGCompression
        case "lzma":
            return LZMACompression
        case "jbig1":
            return JBIG1Compression
        case "jbig2":
            return JBIG2Compression
        case "piz":
            return PizCompression
        case "pxr24":
            return Pxr24Compression
        case "b44":
            return B44Compression
        case "b44a":
            return B44ACompression
        default:
            return UndefinedCompression
        }
    }
    
    private func getFileName(_ path: String) -> String {
        let fileURL = URL(fileURLWithPath: path)
        return fileURL.lastPathComponent
    }
    
    private func getFileSize(_ path: String) -> String {
        let fileManager = FileManager.default
        if let attributes = try? fileManager.attributesOfItem(atPath: path),
           let fileSize = attributes[.size] as? UInt64 {
            return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
        }
        return ""
    }
    
    private func getFileCreationDate(_ path: String) -> String {
        let fileManager = FileManager.default
        if let attributes = try? fileManager.attributesOfItem(atPath: path),
           let creationDate = attributes[.creationDate] as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.string(from: creationDate)
        }
        return ""
    }
    
    private func getImageColorSpace(_ wand: MagickWand) -> String {
        let colorspaceType = MagickGetImageColorspace(wand)
        switch colorspaceType {
        case UndefinedColorspace: return "Undefined"
        case RGBColorspace: return "Linear RGB"
        case GRAYColorspace: return "Greyscale"
        case TransparentColorspace: return "Transparent"
        case OHTAColorspace: return "OHTA"
        case LabColorspace: return "CIE Lab"
        case XYZColorspace: return "CIE XYZ"
        case YCbCrColorspace: return "YCbCr"
        case YCCColorspace: return "PhotoCD YCC"
        case YIQColorspace: return "NTSC YIQ"
        case YPbPrColorspace: return "YPbPr"
        case YUVColorspace: return "YUV"
        case CMYKColorspace: return "Negated Linear RGB with Black Separated"
        case sRGBColorspace: return "sRGB"
        case HSBColorspace: return "Hue, Saturation, Brightness"
        case HSLColorspace: return "Hue, Saturation, Lightness"
        case HWBColorspace: return "Hue, Whiteness, Blackness"
        case Rec601LumaColorspace: return "Rec. 601 Luminance"
        case Rec601YCbCrColorspace: return "Rec. 601 YCbCr"
        case Rec709LumaColorspace: return "Rec. 709 Luminance"
        case Rec709YCbCrColorspace: return "Rec. 709 YCbCr"
        case LogColorspace: return "Logarithmic"
        case CMYColorspace: return "Negated Linear RGB"
        case LuvColorspace: return "CIE Luv"
        case HCLColorspace: return "Hue-Chroma-Luminance"
        case LCHColorspace: return "Cylindrical Luv"
        case LMSColorspace: return "LMS (Long-Medium-Short)"
        case LCHabColorspace: return "Cylindrical Lab"
        case LCHuvColorspace: return "Cylindrical Luv"
        case scRGBColorspace: return "ScRGB"
        case HSIColorspace: return "Hue, Saturation, Intensity"
        case HSVColorspace: return "Hue, Saturation, Value"
        case HCLpColorspace: return "Hue-Chroma-Luminance"
        case YDbDrColorspace: return "YDbDr"
        default: return "Unknown"
        }
    }
    
    private func getImageProfiles(_ wand: MagickWand) -> [String: String] {
        var profiles: [String: String] = [:]
        var profileList: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>? = nil
        var numberOfProfiles: size_t = 0

        profileList = MagickGetImageProfiles(wand, "*", &numberOfProfiles)
        guard let list = profileList, numberOfProfiles > 0 else {
            return profiles
        }

        defer {
            for index in 0..<numberOfProfiles {
                if let profile = list[index] {
                    MagickRelinquishMemory(profile)
                }
            }
            MagickRelinquishMemory(profileList)
        }

        for index in 0..<numberOfProfiles {
            if let key = list[index] {
                let profileName = String(cString: key)
                var profileSize: size_t = 0
                if let profileData = MagickGetImageProfile(wand, key, &profileSize) {
                    let profileValue = Data(bytes: profileData, count: profileSize)
                    profiles[profileName] = String(decoding: profileValue, as: UTF8.self)
                    MagickRelinquishMemory(profileData)
                }
            }
        }

        return profiles
    }
    
    private func getUncompressedFileSize(wand: MagickWand) -> Int64 {
        var blobLength: Int = 0
        if let blob = MagickGetImageBlob(wand, &blobLength) {
            MagickRelinquishMemory(blob)
            return Int64(blobLength)
        }
        return .zero
    }
    
    private func listSupportedFormats() async throws -> [String] {
        var numberFormats: Int = 0
        guard let formats = MagickQueryFormats("*", &numberFormats) else {
            throw ImageProcessorError.unknownError("Failed to list supported formats")
        }

        var supportedFormats: [String] = []
        for i in 0..<numberFormats {
            if let format = formats[Int(i)] {
                supportedFormats.append(String(cString: format))
            }
        }

        MagickRelinquishMemory(formats)

        return supportedFormats
    }
    
    private func deleteCompressedFilesInTempDirectory() async throws {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory

        let files = try fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
        for file in files {
            if file.lastPathComponent.contains("_compressed") {
                try fileManager.removeItem(at: file)
            }
        }
    }
}

// MARK: - Handle Chaining Methods

extension ImageProcessor {
    
    private func compressImage(_ wand: MagickWand, quality: Double) async throws {
        let imageFormat = try getImageFormat(wand)
        let compressionType = compressionType(for: imageFormat)
        
        if MagickSetImageCompression(wand, compressionType) == MagickFalse {
            throw ImageProcessorError.unknownError("Failed to set compression type: \(compressionType)")
        }
        
        if MagickSetImageCompressionQuality(wand, Int(quality)) == MagickFalse {
            throw ImageProcessorError.unknownError("Failed to set compression quality: \(quality)")
        }
        let fileSize = getUncompressedFileSize(wand: wand)
#if DEBUG
        print("Image compression: \(compressionType) \(quality) - Size: \(fileSize)")
#endif
    }
    
    private func resizeImage(_ wand: MagickWand, percent: Double) async throws {
        let width = MagickGetImageWidth(wand)
        let height = MagickGetImageHeight(wand)
        let newWidth = Int(Double(width) * percent)
        let newHeight = Int(Double(height) * percent)
        
        if MagickResizeImage(wand, newWidth, newHeight, LanczosFilter, 1.0) == MagickFalse {
            throw ImageProcessorError.unknownError("Failed to resize image")
        }
        let fileSize = getUncompressedFileSize(wand: wand)
#if DEBUG
        print("Image resized: \(percent) - Size: \(fileSize)")
#endif
    }
    
    private func convertImage(_ wand: MagickWand, format: String) async throws {
        let currentFormat = try getImageFormat(wand)
        
        if currentFormat.lowercased() != format.lowercased() && format != "None" {
            if MagickSetImageFormat(wand, format) == MagickFalse {
                throw ImageProcessorError.unknownError("Failed to set image format: \(format)")
            }
        }
        let fileSize = getUncompressedFileSize(wand: wand)
#if DEBUG
        print("Image converted: \(format) - Size: \(fileSize)")
#endif
    }
}
