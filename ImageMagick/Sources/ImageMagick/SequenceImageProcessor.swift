//
//  SequenceImageProcessor.swift
//  ImageMagick
//
//  Created by Thanh Hai Khong on 13/1/25.
//

import ImageMagickObjC
import Foundation
import UIKit

@available(iOS 13.0.0, *)
public actor SequenceImageProcessor {
    public static let shared = SequenceImageProcessor()
    
    private var wand: MagickWand
    private var totalProgress: Double = 0.0
    private var continuation: AsyncStream<SequenceProgress>.Continuation?
    
    private init() {
        MagickWandGenesis()
        self.wand = NewMagickWand()
    }
    
    private lazy var progressCallback: ProgressMonitorCallback = { [weak self] text, offset, span, _ in
        let imageProgress = Double(offset) / Double(span) * 100
        
        if let description = text {
            #if DEBUG
            print("- INTERNAL Image Progress: \(imageProgress)% - Step: \(String(cString: description))")
            #endif
        }
        
        return MagickTrue
    }
    
    public func processImages(_ imagePaths: [String], input: CompressionInput) async throws -> AsyncStream<SequenceProgress> {
        return AsyncStream { continuation in
            self.continuation = continuation
            var results: [SequenceCompressionResult] = []
            var processedImagesCount = 0
            
            MagickSetProgressMonitor(wand, progressCallback, nil)
            
            for path in imagePaths {
                do {
                    try loadImage(from: path, to: wand)
                    
                    let originalSize = getUncompressedFileSize(wand: wand)
                    
                    try convertImage(wand, format: input.format)
                    try resizeImage(wand, percent: input.percent)
                    try compressImage(wand, quality: input.quality)
                    
                    let compressedSize = getUncompressedFileSize(wand: wand)
                    
                    let outputFilePath = generateOutputPath(imagePaths[processedImagesCount])
                    try writeImage(wand, to: outputFilePath)
                    
                    results.append(.init(
                        originalSize: originalSize,
                        compressedSize: compressedSize,
                        outputPath: outputFilePath,
                        status: .success)
                    )
                } catch {
                    results.append(.init(status: .failed(error)))
                }
                
                processedImagesCount += 1
                totalProgress = Double(processedImagesCount) / Double(imagePaths.count) * 100

                self.continuation?.yield(.inProcessing(totalProgress))
                
                clearAllImagesFromWand(wand)
            }
            
            self.continuation?.yield(.finished(results))
            self.continuation = nil
        }
    }
    
    public func processImages(_ imagePaths: [String], input: CompressionInput, onProgress: @escaping (Double) -> Void) async -> [SequenceCompressionResult] {
        var results: [SequenceCompressionResult] = []
        var processedImagesCount = 0
        
        for path in imagePaths {
            do {
                try loadImage(from: path, to: wand)
                
                let originalSize = getUncompressedFileSize(wand: wand)
                
                try convertImage(wand, format: input.format)
                try resizeImage(wand, percent: input.percent)
                try compressImage(wand, quality: input.quality)
                
                let compressedSize = getUncompressedFileSize(wand: wand)
                
                let outputFilePath = generateOutputPath(imagePaths[processedImagesCount])
                try writeImage(wand, to: outputFilePath)
                
                results.append(.init(
                    originalSize: originalSize,
                    compressedSize: compressedSize,
                    outputPath: outputFilePath,
                    status: .success)
                )
            } catch {
                results.append(.init(status: .failed(error)))
            }
            
            processedImagesCount += 1
            totalProgress = Double(processedImagesCount) / Double(imagePaths.count) * 100

            onProgress(totalProgress)
            
            clearAllImagesFromWand(wand)
        }
        
        return results
    }
    
    public func processImages(_ imagePaths: [String], input: CompressionInput) async -> [SequenceCompressionResult] {
        var results: [SequenceCompressionResult] = []
        var processedImagesCount = 0
        
        MagickSetProgressMonitor(wand, progressCallback, nil)
        
        for path in imagePaths {
            do {
                try loadImage(from: path, to: wand)
                
                let originalSize = getUncompressedFileSize(wand: wand)
                
                try convertImage(wand, format: input.format)
                try resizeImage(wand, percent: input.percent)
                try compressImage(wand, quality: input.quality)
                
                let compressedSize = getUncompressedFileSize(wand: wand)
                
                let outputFilePath = generateOutputPath(imagePaths[processedImagesCount])
                try writeImage(wand, to: outputFilePath)
                
                results.append(.init(
                    originalSize: originalSize,
                    compressedSize: compressedSize,
                    outputPath: outputFilePath,
                    status: .success)
                )
            } catch {
                results.append(.init(status: .failed(error)))
            }
            
            processedImagesCount += 1
            totalProgress = Double(processedImagesCount) / Double(imagePaths.count) * 100
            
            clearAllImagesFromWand(wand)
        }
        
        return results
    }
    
    public func cleanUp() async throws {
        clearAllImagesFromWand(wand)
        try await deleteCompressedFilesInTempDirectory()
    }
}

extension SequenceImageProcessor {
    private func iterateFrames(process: (MagickWandPointer) throws -> Void) throws {
        MagickSetFirstIterator(wand)
        repeat {
            try process(&wand)
        } while MagickNextImage(wand) == MagickTrue
    }
    
    private func compressImage(_ wand: MagickWand, quality: Double) throws {
        let imageFormat = try getImageFormat(wand)
        let compressionType = compressionType(for: imageFormat)
        
        if MagickSetImageCompression(wand, compressionType) == MagickFalse {
            throw ImageProcessorError.unknownError("Failed to set compression type: \(compressionType)")
        }
        
        if MagickSetImageCompressionQuality(wand, Int(quality)) == MagickFalse {
            throw ImageProcessorError.unknownError("Failed to set compression quality: \(quality)")
        }
    }
    
    private func resizeImage(_ wand: MagickWand, percent: Double) throws {
        let width = MagickGetImageWidth(wand)
        let height = MagickGetImageHeight(wand)
        let newWidth = Int(Double(width) * percent)
        let newHeight = Int(Double(height) * percent)
        
        if MagickResizeImage(wand, newWidth, newHeight, LanczosFilter, 1.0) == MagickFalse {
            throw ImageProcessorError.unknownError("Failed to resize image")
        }
    }
    
    private func convertImage(_ wand: MagickWand, format: String) throws {
        let currentFormat = try getImageFormat(wand)
        
        if currentFormat.lowercased() != format.lowercased() && format != "None" {
            if MagickSetImageFormat(wand, format) == MagickFalse {
                throw ImageProcessorError.unknownError("Failed to set image format: \(format)")
            }
        }
    }
}

extension SequenceImageProcessor {
    private func writeImage(_ wand: MagickWand, to path: String) throws {
        guard MagickWriteImage(wand, path) != MagickFalse else {
            throw ImageProcessorError.failedToWriteImage("Failed to write image to \(path)")
        }
    }
    
    private func generateOutputPath(_ path: String) -> String {
        let fileName = getFileName(path)
        let fileExtension = (fileName as NSString).pathExtension
        let outputPath = path.replacingOccurrences(of: ".\(fileExtension)", with: "") + "_compressed.\(fileExtension)"
        return outputPath
    }
    
    private func getFileName(_ path: String) -> String {
        let fileURL = URL(fileURLWithPath: path)
        return fileURL.lastPathComponent
    }
    
    private func clearAllImagesFromWand(_ wand: MagickWand) {
        ClearMagickWand(wand)
    }
    
    private func loadImages(_ imagePaths: [String]) async throws {
        for path in imagePaths {
            try loadImage(from: path, to: wand)
        }
    }
    
    private func loadImage(from path: String, to wand: MagickWand) throws {
        if MagickReadImage(wand, path) == MagickFalse {
            throw ImageProcessorError.failedToReadImage(path)
        }
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
    
    private func getUncompressedFileSize(wand: MagickWand) -> Int64 {
        var blobLength: Int = 0
        if let blob = MagickGetImageBlob(wand, &blobLength) {
            MagickRelinquishMemory(blob)
            return Int64(blobLength)
        }
        return .zero
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
