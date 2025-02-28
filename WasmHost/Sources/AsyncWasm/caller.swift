//
//  caller.swift
//  WasmHost
//
//  Created by L7Studio on 9/1/25.
//
import Foundation
import SwiftProtobuf
#if canImport(UIKit)
import UIKit
#endif
public protocol CallerID {}

extension CallerID {
    func to_asyncify_call_id() throws -> String {
        let elms = String(reflecting: self).components(separatedBy: ".")
        return try elms.dropFirst(elms.count - 2)
            .map({ try $0.snakecased().uppercased() }).joined(separator: "_")
    }
    
}
extension String {
    func snakecased() throws -> String {
        let pattern = "([a-z])([A-Z])"
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.utf16.count)
        let result = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
        return result.lowercased()
    }
}

extension AsyncifyCommand.Call {
    public init(id: String, args: [String: Google_Protobuf_Value] = [:]) {
        self.init()
        self.id = id
        self.args = Google_Protobuf_Struct(fields: args)
    }
    public init(id: CallerID, args: [String: Google_Protobuf_Value] = [:]) throws {
        self.init()
        self.id = try id.to_asyncify_call_id()
        self.args = Google_Protobuf_Struct(fields: args)
    }
}
extension AsyncifyCommand {
    public init(call: Call) {
        self.init()
        self.requestID = UUID().uuidString
        self.kind = .call
        self.call = call
        self.options.contentType = "application/json"
        self.options.bundleID = Bundle.main.bundleIdentifier ?? ""
#if canImport(UIKit)
        self.options.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
#endif
        self.options.countryCode = Locale.current.identifier
        self.options.languageCode = Locale.current.languageCode ?? "en"
        self.options.regionCode = Locale.current.regionCode ?? "US"
        self.options.appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ("Unknown")
    }
}
