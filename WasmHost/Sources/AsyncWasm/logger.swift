//
//  logger.swift
//  WasmHost
//
//  Created by L7Studio on 18/2/25.
//
import OSLog

public class WALogger {
    public static let guest = WALogger(category: "guest")
    public static let host = WALogger(category: "host")
    let subsystem: String
    let category: String
    lazy var _log = OSLog(subsystem: self.subsystem, category: self.category)
    public init(subsystem: String = "wasm", category: String) {
        self.subsystem = subsystem
        self.category = category
    }
    public func debug(_ fmt: String, _ args: Any...) {
        if let val = ProcessInfo.processInfo.environment["WASM_ENABLE_LOGGING"] {
            if val.boolValue ?? false {
                os_log(
                    "%{public}@",
                    log: self._log,
                    type: .debug,
                    String(format: fmt, args))
            }
        }
        
    }
}
