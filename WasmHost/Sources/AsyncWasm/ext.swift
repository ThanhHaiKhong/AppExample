//
//  ext.swift
//  WasmHost
//
//  Created by L7Studio on 18/2/25.
//
import Foundation

public func backoff(attempts: Int) -> TimeInterval {
    if attempts > 13 {
        return 2 * 60
    }
    let delay = pow(Double(attempts), M_E) * 0.1
    return delay
}

extension UInt32 {
    var hex: String {
        "0x" + String(self, radix: 16)
    }
}

extension String {
    var boolValue: Bool? {
        switch self.lowercased() {
        case "true", "yes", "1": return true
        case "false", "no", "0": return false
        default: return nil // Invalid boolean string
        }
    }
}
