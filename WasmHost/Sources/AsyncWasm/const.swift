//
//  const.swift
//  WasmHost
//
//  Created by L7Studio on 18/2/25.
//
import Foundation

@objc(AsyncifyWasmConstants)
public class Constants: NSObject {
    @objc
    public static let errorDomain = "com.l7mobile.wasm.async"
    
    public enum Error: Int, LocalizedError {
        case requiredRecreateEngineError = 50000
        case maximumRetryExceededError
        case missingSharedPrefereceError
        public var errorDescription: String? {
            switch self {
            case .requiredRecreateEngineError: "recreate the engine to use."
            case .maximumRetryExceededError: "maximum retry count exceeded"
            case .missingSharedPrefereceError: "missing shared preference"
            }
        }
        
        public func error(reason: Swift.Error? = nil) -> Swift.Error {
            var info = [NSLocalizedDescriptionKey: self.localizedDescription]
            if let reason {
                info[NSLocalizedFailureReasonErrorKey] = reason.localizedDescription
            }
            return NSError(domain: Constants.errorDomain,
                           code: self.rawValue,
                           userInfo: info)
        }
    }
}

