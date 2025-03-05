// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import AsyncWasm
import MusicWasm
import WasmSwiftProtobuf

@objc public protocol MusicWasmManagerDelegate: AnyObject {
    func wasmEngineDidUpdate(_ newEngine: MusicWasmEngine)
    func wasmDownloadProgress(_ progress: Float)
    func wasmDownloadCompleted(newPath: String)
    func wasmDownloadFailed(error: Error)
}

@objcMembers
public class MusicWasmManager: NSObject, @unchecked Sendable {
    
    @objc(sharedInstance)
    public static let shared = MusicWasmManager()
    
    private var wasmEngine: MusicWasmEngine?
    private var wasmPath: String?
    
    public weak var delegate: MusicWasmManagerDelegate?
    
    private override init() {
        super.init()
    }
    
    public func initialize(withWasmPath path: String) {
        self.wasmPath = path
        setupWasmFile()
    }
    
    public func updateWasmPath(_ newPath: String) {
        self.wasmPath = newPath
        setupWasmFile()
    }
    
    private func setupWasmFile() {
        guard let wasmPath = wasmPath else {
            print("⚠️ Error: Wasm path is not set!")
            return
        }
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let wasmDirectory = documentsDirectory.appendingPathComponent("wasm")
        
        // Tạo thư mục `wasm` nếu chưa có
        if !fileManager.fileExists(atPath: wasmDirectory.path) {
            do {
                try fileManager.createDirectory(at: wasmDirectory, withIntermediateDirectories: true, attributes: nil)
                print("📁 Created wasm directory: \(wasmDirectory.path)")
            } catch {
                print("⚠️ Error creating wasm directory: \(error)")
                return
            }
        }
        
        // Sao chép file `.wasm` vào `wasm` folder nếu chưa có
        let destinationURL = wasmDirectory.appendingPathComponent((wasmPath as NSString).lastPathComponent)
        
        if !fileManager.fileExists(atPath: destinationURL.path) {
            do {
                try fileManager.copyItem(at: URL(fileURLWithPath: wasmPath), to: destinationURL)
                print("📄 Copied wasm file to: \(destinationURL.path)")
            } catch {
                print("⚠️ Error copying wasm file: \(error)")
                return
            }
        } else {
            print("✅ Wasm file already exists at: \(destinationURL.path)")
        }
        
        // Cập nhật đường dẫn wasmPath thành file trong Document Directory
        self.wasmPath = destinationURL.path
        
        // Tạo engine từ file mới
        updateWasmEngine()
    }
    
    private func updateWasmEngine() {
        guard let wasmPath = wasmPath else {
            print("⚠️ Error: Wasm path is not set!")
            return
        }
        
        let wasmURL = URL(fileURLWithPath: wasmPath)
        
        do {
            wasmEngine = try MusicWasmEngine(file: wasmURL)
            if let wasmEngine {
                var options = MusicOptions()
                options.provider = "youtube"
                wasmEngine.copts["music"] = try options.serializedData()
            }
            
            notifyUpdate()
        } catch {
            print("⚠️ Error initializing WasmEngine: \(error)")
        }
    }
    
    private func notifyUpdate() {
        if let wasmEngine = wasmEngine {
            NotificationCenter.default.post(name: NSNotification.Name("WasmEngineUpdated"), object: wasmEngine)
            delegate?.wasmEngineDidUpdate(wasmEngine)
        }
    }
    
    public func getCurrentWasmEngine() -> MusicWasmEngine? {
        return wasmEngine
    }
    
    public func updateNewVersionIfNeeded() {
        guard let wasmEngine = wasmEngine else {
            return
        }
        
        Task {
            do {
                let versionJSON = try await wasmEngine.version().jsonString()
                if let versionData = versionJSON.data(using: .utf8) {
                    let currentVersion = try EngineVersion(jsonUTF8Data: versionData)
                    if currentVersion.hasNext {
                        let nextVersion = currentVersion.next
                        let urlString = nextVersion.url
                        
                        if let url = URL(string: urlString) {
                            let newWasmPath = try await downloadWasmFile(from: url)
                            DispatchQueue.main.async {
                                self.updateWasmPath(newWasmPath)
                            }
                        }
                    } else {
                        print("✅ No new version available.")
                    }
                }
            } catch {
                print("⚠️ Error checking for new version: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Download File with Progress
        
    private var downloadTask: URLSessionDownloadTask?
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    private func downloadWasmFile(from url: URL) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let wasmDirectory = documentsDirectory.appendingPathComponent("wasm")
            
            if !fileManager.fileExists(atPath: wasmDirectory.path) {
                do {
                    try fileManager.createDirectory(at: wasmDirectory, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    continuation.resume(throwing: error)
                    return
                }
            }
            
            let destinationURL = wasmDirectory.appendingPathComponent(url.lastPathComponent)
            
            let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
                let fileManager = FileManager()
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let tempURL = tempURL else {
                    continuation.resume(throwing: NSError(domain: "DownloadError", code: -1, userInfo: nil))
                    return
                }
                
                do {
                    if fileManager.fileExists(atPath: destinationURL.path) {
                        try fileManager.removeItem(at: destinationURL)
                    }
                    try fileManager.moveItem(at: tempURL, to: destinationURL)
                    print("📄 Downloaded wasm file to: \(destinationURL.path)")
                    
                    continuation.resume(returning: destinationURL.path)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            task.resume()
        }
    }
}

// MARK: - URLSessionDownloadDelegate

extension MusicWasmManager: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            print("📦 Download progress: \(progress)")
            self.delegate?.wasmDownloadProgress(progress)
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let wasmDirectory = documentsDirectory.appendingPathComponent("wasm")
        let destinationURL = wasmDirectory.appendingPathComponent(downloadTask.originalRequest?.url?.lastPathComponent ?? "default.wasm")
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            try fileManager.moveItem(at: location, to: destinationURL)
            
            DispatchQueue.main.async {
                self.delegate?.wasmDownloadCompleted(newPath: destinationURL.path)
                self.updateWasmPath(destinationURL.path)
            }
        } catch {
            DispatchQueue.main.async {
                self.delegate?.wasmDownloadFailed(error: error)
            }
        }
    }
}
